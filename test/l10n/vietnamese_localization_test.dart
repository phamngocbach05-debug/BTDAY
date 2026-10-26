import 'package:daily_you/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Kiểm thử Việt hóa ứng dụng Daily You (Vietnamese Localization)', () {
    test('Tải thành công bộ ngôn ngữ Tiếng Việt (vi) và mặc định (en)', () async {
      final vi = await AppLocalizations.delegate.load(const Locale('vi'));
      final en = await AppLocalizations.delegate.load(const Locale('en'));

      expect(vi.pageHomeTitle, equals('Trang chủ'));
      expect(vi.pageGalleryTitle, equals('Thư viện'));
      expect(vi.pageStatisticsTitle, equals('Thống kê'));
      expect(vi.pageSettingsTitle, equals('Cài đặt'));
      expect(vi.pageCalendarTitle, equals('Lịch'));

      expect(en.pageHomeTitle, equals('Trang chủ'));
      expect(en.pageSettingsTitle, equals('Cài đặt'));
    });

    test('Kiểm tra các chuỗi số nhiều (ICU Plurals) và tham số (Placeholders)', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('vi'));

      expect(l10n.flashbackWeek(1), equals('1 tuần trước'));
      expect(l10n.flashbackWeek(3), equals('3 tuần trước'));
      expect(l10n.flashbackMonth(2), equals('2 tháng trước'));
      expect(l10n.flashbackYear(1), equals('1 năm trước'));

      expect(l10n.logCount(5), equals('5 nhật ký'));
      expect(l10n.dayCount(10), equals('10 ngày'));
      expect(l10n.wordCount(120), equals('120 từ'));

      expect(l10n.streakCurrent(7), equals('Chuỗi hiện tại 7'));
      expect(l10n.streakLongest(14), equals('Chuỗi dài nhất 14'));
      expect(l10n.streakGreatDays(5), equals('Ngày tuyệt vời 5'));
      expect(l10n.streakSinceBadDay(3), equals('Số ngày từ sau ngày tệ 3'));

      expect(l10n.chartSummaryTitle('Tâm trạng'), equals('Tổng quan Tâm trạng'));
      expect(l10n.chartByDayTitle('Tâm trạng'), equals('Tâm trạng theo ngày'));
      expect(l10n.chartOverTimeTitle('Tâm trạng'), equals('Tâm trạng theo thời gian'));
      expect(l10n.chartDistributionTitle('Tâm trạng'), equals('Phân bổ Tâm trạng'));

      expect(
        l10n.deleteTagMessage(0, 'Yêu thích'),
        equals('Xóa "Yêu thích"?'),
      );
      expect(
        l10n.deleteTagMessage(1, 'Yêu thích'),
        equals('Xóa "Yêu thích"? Thẻ này đang được dùng trong 1 nhật ký.'),
      );
      expect(
        l10n.deleteTagMessage(4, 'Yêu thích'),
        equals('Xóa "Yêu thích"? Thẻ này đang được dùng trong 4 nhật ký.'),
      );

      expect(
        l10n.deleteCategoryMessage(2, 'Cảm xúc'),
        equals('Xóa "Cảm xúc"? 2 thẻ thuộc danh mục này cũng sẽ bị xóa.'),
      );

      expect(l10n.creatingBackupStatus(50), equals('Đang tạo bản sao lưu… 50%'));
      expect(l10n.migratingImagesStatus(3, 10), equals('Đang di chuyển ảnh… 3/10'));
    });

    test('Kiểm tra toàn bộ thẻ mặc định, mẫu nhật ký và lời chào mừng bằng Tiếng Việt', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('vi'));

      expect(l10n.tagFavoriteName, equals('Yêu thích'));
      expect(l10n.tagEnergyName, equals('Năng lượng'));
      expect(l10n.tagCategoryActivitiesName, equals('Hoạt động'));
      expect(l10n.tagCategoryEmotionsName, equals('Cảm xúc'));
      expect(l10n.templateDefaultSummaryTitle, equals('Tóm tắt ngày'));
      expect(l10n.templateDefaultReflectionTitle, equals('Suy ngẫm'));
      expect(l10n.welcomeLogBodyText, contains('Chào mừng bạn đến với Daily You'));
    });
  });
}

