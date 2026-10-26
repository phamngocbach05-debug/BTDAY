# Daily You (Phiên bản Việt hóa) - BTDAY

<p align="center">
  <img width="500" src="assets/banner.gif" alt="Daily You Logo">
</p>

> **Daily You - Mỗi ngày trôi qua đều đáng để ghi nhớ…**  
> Dự án triển khai, tối ưu hóa và **Việt hóa toàn diện (100%)** từ mã nguồn mở Daily You.
> 
> **Tác giả:** [phamngocbach05-debug](https://github.com/phamngocbach05-debug)  
> **Tên bài nộp:** `BTDAY`

---

## 📋 Danh sách kiểm tra hoàn thành (Checklist)

| STT | Yêu cầu | Trạng thái | Chi tiết triển khai |
| :--- | :--- | :---: | :--- |
| 1 | **Thiết lập môi trường & cài đặt thư viện** | ✅ Đạt | Môi trường Flutter 3.47.2, Dart 3.13.2, VS Community 2022 và đầy đủ packages. |
| 2 | **Build và chạy ứng dụng trên máy cục bộ (localhost)** | ✅ Đạt | Hỗ trợ nền tảng Web qua Web Storage / IndexedDB, phục vụ thành công trên `http://localhost:8080`. |
| 3 | **Rà soát toàn bộ tệp ngôn ngữ, UI & thông báo** | ✅ Đạt | Rà soát 100% tệp `intl_vi.arb`, `intl_en.arb`, hệ thống kênh thông báo Android/Linux và các dialogs. |
| 4 | **Dịch & thay thế toàn bộ nội dung sang tiếng Việt** | ✅ Đạt | Dịch chuẩn ngữ cảnh chuyên ngành nhật ký, tâm trạng, hồi tưởng, mẫu ghi chép. Ngôn ngữ mặc định: `Locale('vi')`. |
| 5 | **Kiểm tra chức năng không gây lỗi hiển thị** | ✅ Đạt | Đã kiểm thử qua bộ Unit Test tại `test/l10n/vietnamese_localization_test.dart` (ICU plurals, placeholders, default tags). |

---

## ✨ Các tính năng chính của Daily You

- ✍️ **Ghi nhật ký hàng ngày:** Viết nhật ký, suy ngẫm hoặc thói quen với định dạng văn bản Markdown phong phú.
- 📈 **Theo dõi tâm trạng:** Đánh giá cảm xúc từ rất buồn đến rất vui, vẽ biểu đồ chuỗi liên tiếp (streaks) và phân bổ tâm trạng.
- 🖼️ **Lưu giữ kỷ niệm đa phương tiện:** Đính kèm hình ảnh, video và ghi âm trực tiếp vào bài nhật ký.
- 🕰️ **Hồi tưởng (Flashbacks):** Tính năng "Ngày này năm xưa", xem lại nhật ký cách đây 1 tuần, 1 tháng, 1 năm.
- 🔔 **Nhắc nhở thông minh:** Lên lịch nhắc nhở nhẹ nhàng hàng ngày để duy trì thói quen viết.
- 🔒 **Quyền riêng tư & Ngoại tuyến:** Hoạt động hoàn toàn Offline, không cần tài khoản, hỗ trợ khóa ứng dụng bằng mật khẩu/sinh trắc học.
- 📦 **Sao lưu & Đồng bộ:** Hỗ trợ xuất file bản sao lưu được mã hóa bảo mật.

---

## 🚀 Hướng dẫn cài đặt & Khởi chạy

### 1. Yêu cầu môi trường
- Flutter SDK `>= 3.0.0`
- Trình duyệt Chrome hoặc môi trường Windows Desktop (Visual Studio C++)

### 2. Cài đặt thư viện
```bash
git clone https://github.com/phamngocbach05-debug/BTDAY.git
cd BTDAY
flutter pub get
```

### 3. Chạy ứng dụng

#### Cách 1: Chạy trực tiếp bản Web Localhost (Khuyên dùng)
```bash
cd build/web
python -m http.server 8080
```
Truy cập trình duyệt tại: **`http://localhost:8080`**

#### Cách 2: Chạy qua Flutter với Chrome
```bash
flutter run -d chrome --release
```

#### Cách 3: Chạy ứng dụng Desktop Windows
```bash
flutter run -d windows
```

---

## 📁 Cấu trúc thư mục ngôn ngữ & cốt lõi
- `lib/l10n/intl_vi.arb`: Toàn bộ từ điển bản dịch tiếng Việt gốc.
- `lib/l10n/generated/`: Mã Dart localization được sinh tự động.
- `lib/pages/`: Toàn bộ giao diện các màn hình (Home, Gallery, Statistics, Settings, Edit Entry).
- `lib/providers/`: Quản lý trạng thái và dữ liệu mặc định (thẻ, mẫu nhật ký tiếng Việt).
- `test/l10n/vietnamese_localization_test.dart`: Bộ kiểm thử tự động hóa Việt hóa.

---
**Giấy phép:** GPL-3.0 License.
