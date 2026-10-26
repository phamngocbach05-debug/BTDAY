import 'package:daily_you/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppLocalizations loads Vietnamese locale', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('vi'));
    expect(l10n.appTitle, equals('Daily You'));
    expect(l10n.pageHomeTitle, equals('Trang chủ'));
  });
}
