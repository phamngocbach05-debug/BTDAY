// Copyright (C) 2026 Demizo and contributors
// SPDX-License-Identifier: GPL-3.0-only
// Additional terms under GPLv3 section 7 apply; see ADDITIONAL_TERMS.md.

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class WebDatabase implements Database, Transaction {
  static const String _storageKey = 'daily_you_web_db_v1';

  final Map<String, List<Map<String, Object?>>> _tables = {};
  final Map<String, int> _autoIncrement = {};
  bool _isOpen = true;
  int _version = 6;
  bool isFirstCreation = false;

  static Future<WebDatabase> open({
    required int version,
    OnDatabaseCreateFn? onCreate,
  }) async {
    final db = WebDatabase();
    db._version = version;
    await db._load();
    if (db.isFirstCreation && onCreate != null) {
      await onCreate(db, version);
      await db._save();
    }
    return db;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      isFirstCreation = true;
      return;
    }
    try {
      final decoded = json.decode(raw) as Map<String, dynamic>;
      final tablesJson = decoded['tables'] as Map<String, dynamic>? ?? {};
      final autoIncJson = decoded['autoInc'] as Map<String, dynamic>? ?? {};

      for (final entry in tablesJson.entries) {
        final rows = (entry.value as List<dynamic>)
            .map((r) => Map<String, Object?>.from(r as Map))
            .toList();
        _tables[entry.key] = rows;
      }
      for (final entry in autoIncJson.entries) {
        _autoIncrement[entry.key] = (entry.value as num).toInt();
      }
    } catch (_) {
      isFirstCreation = true;
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = json.encode({
      'tables': _tables,
      'autoInc': _autoIncrement,
    });
    await prefs.setString(_storageKey, payload);
  }

  List<Map<String, Object?>> _table(String name) =>
      _tables.putIfAbsent(name, () => <Map<String, Object?>>[]);

  bool _matchesWhere(
    Map<String, Object?> row,
    String? where,
    List<Object?>? whereArgs,
  ) {
    if (where == null || where.trim().isEmpty) return true;
    final match = RegExp(r'^(\w+)\s*=\s*\?$').firstMatch(where.trim());
    if (match != null && whereArgs != null && whereArgs.isNotEmpty) {
      final col = match.group(1)!;
      return row[col] == whereArgs.first;
    }
    return true;
  }

  int _compareValues(Object? a, Object? b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    if (a is num && b is num) return a.compareTo(b);
    return a.toString().compareTo(b.toString());
  }

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    final trimmed = sql.trim();
    final createMatch =
        RegExp(r'^CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?(\w+)', caseSensitive: false)
            .firstMatch(trimmed);
    if (createMatch != null) {
      _table(createMatch.group(1)!);
    }
  }

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) async => 0;

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    final rows = _table(table);
    final row = Map<String, Object?>.from(values);
    int id;
    if (row['id'] is int) {
      id = row['id'] as int;
      final currentMax = _autoIncrement[table] ?? 0;
      if (id > currentMax) _autoIncrement[table] = id;
    } else {
      id = (_autoIncrement[table] ?? 0) + 1;
      _autoIncrement[table] = id;
      row['id'] = id;
    }
    rows.removeWhere((existing) => existing['id'] == id);
    rows.add(row);
    await _save();
    return id;
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    if (table == 'sqlite_master') {
      return [
        for (final name in _tables.keys) {'name': name, 'type': 'table'},
      ];
    }
    final rows = _table(table)
        .where((r) => _matchesWhere(r, where, whereArgs))
        .map((r) => Map<String, Object?>.from(r))
        .toList();

    if (orderBy != null && orderBy.trim().isNotEmpty) {
      final clauses = orderBy.split(',').map((c) => c.trim()).toList();
      rows.sort((a, b) {
        for (final clause in clauses) {
          final parts = clause.split(RegExp(r'\s+'));
          final col = parts.first;
          final desc =
              parts.length > 1 && parts[1].toUpperCase() == 'DESC';
          final cmp = _compareValues(a[col], b[col]);
          if (cmp != 0) return desc ? -cmp : cmp;
        }
        return 0;
      });
    }

    var result = rows;
    if (offset != null && offset > 0) {
      result = result.skip(offset).toList();
    }
    if (limit != null && limit >= 0) {
      result = result.take(limit).toList();
    }
    return result;
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    if (sql.toUpperCase().contains('PRAGMA INTEGRITY_CHECK')) {
      return [
        {'integrity_check': 'ok'}
      ];
    }
    return [];
  }

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) async => 0;

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    final rows = _table(table);
    var count = 0;
    for (var i = 0; i < rows.length; i++) {
      if (_matchesWhere(rows[i], where, whereArgs)) {
        rows[i] = {...rows[i], ...values};
        count++;
      }
    }
    await _save();
    return count;
  }

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) async => 0;

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final rows = _table(table);
    final before = rows.length;
    rows.removeWhere((r) => _matchesWhere(r, where, whereArgs));
    final removed = before - rows.length;
    await _save();
    return removed;
  }

  @override
  Batch batch() => _WebBatch(this);

  @override
  Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action, {
    bool? exclusive,
  }) async {
    return await action(this);
  }

  @override
  Future<T> readTransaction<T>(Future<T> Function(Transaction txn) action) async {
    return await action(this);
  }

  @override
  Future<void> close() async {
    await _save();
    _isOpen = false;
  }

  @override
  bool get isOpen => _isOpen;

  @override
  String get path => 'daily_you_web.db';

  Future<int> getVersion() async => _version;

  Future<void> setVersion(int version) async {
    _version = version;
  }

  @override
  Future<T> devInvokeMethod<T>(String method, [Object? arguments]) =>
      throw UnimplementedError();

  @override
  Future<T> devInvokeSqlMethod<T>(
    String method,
    String sql, [
    List<Object?>? arguments,
  ]) =>
      throw UnimplementedError();

  @override
  Database get database => this;

  @override
  Future<QueryCursor> queryCursor(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
    int? bufferSize,
  }) =>
      throw UnimplementedError();

  @override
  Future<QueryCursor> rawQueryCursor(
    String sql,
    List<Object?>? arguments, {
    int? bufferSize,
  }) =>
      throw UnimplementedError();
}

class _WebBatch implements Batch {
  final WebDatabase _db;
  final List<Future<Object?> Function()> _ops = [];

  _WebBatch(this._db);

  @override
  int get length => _ops.length;

  @override
  Future<List<Object?>> commit({
    bool? exclusive,
    bool? noResult,
    bool? continueOnError,
  }) async {
    final results = <Object?>[];
    for (final op in _ops) {
      results.add(await op());
    }
    return results;
  }

  @override
  Future<List<Object?>> apply({bool? noResult, bool? continueOnError}) =>
      commit(noResult: noResult, continueOnError: continueOnError);

  @override
  void insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) {
    _ops.add(() => _db.insert(
          table,
          values,
          nullColumnHack: nullColumnHack,
          conflictAlgorithm: conflictAlgorithm,
        ));
  }

  @override
  void update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) {
    _ops.add(() => _db.update(
          table,
          values,
          where: where,
          whereArgs: whereArgs,
          conflictAlgorithm: conflictAlgorithm,
        ));
  }

  @override
  void delete(String table, {String? where, List<Object?>? whereArgs}) {
    _ops.add(() => _db.delete(table, where: where, whereArgs: whereArgs));
  }

  @override
  void execute(String sql, [List<Object?>? arguments]) {
    _ops.add(() => _db.execute(sql, arguments));
  }

  @override
  void rawInsert(String sql, [List<Object?>? arguments]) {
    _ops.add(() => _db.rawInsert(sql, arguments));
  }

  @override
  void rawUpdate(String sql, [List<Object?>? arguments]) {
    _ops.add(() => _db.rawUpdate(sql, arguments));
  }

  @override
  void rawDelete(String sql, [List<Object?>? arguments]) {
    _ops.add(() => _db.rawDelete(sql, arguments));
  }

  @override
  void query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) {
    _ops.add(() => _db.query(
          table,
          distinct: distinct,
          columns: columns,
          where: where,
          whereArgs: whereArgs,
          groupBy: groupBy,
          having: having,
          orderBy: orderBy,
          limit: limit,
          offset: offset,
        ));
  }

  @override
  void rawQuery(String sql, [List<Object?>? arguments]) {
    _ops.add(() => _db.rawQuery(sql, arguments));
  }
}
