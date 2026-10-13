# Máy tính FX Pro – iPhone / iPad

Ứng dụng SwiftUI lấy cảm hứng từ máy tính khoa học Casio fx-500, không sử dụng nhãn hiệu hay thiết kế công nghiệp độc quyền của Casio.

## Tính năng
- **Khoa học:** cộng/trừ/nhân/chia, lũy thừa, căn, sin/cos/tan (DEG/RAD), log/ln, giai thừa, phần trăm, π, e, Ans, bộ nhớ M+/M−/MR/MC, lịch sử.
- **Programmer:** nhập/xem HEX, DEC, OCT, BIN đồng thời; phép tính trên số nguyên không dấu 64 bit; AND/OR/XOR/NOT, dịch trái/phải, MOD, cộng/trừ/nhân/chia; tương tác 64 bit riêng lẻ.
- Giao diện tiếng Việt, chạy trên iOS 16 trở lên.

## Build trên GitHub Actions (không cần máy Mac)
1. Tạo repository GitHub mới, tải toàn bộ nội dung thư mục này lên (bao gồm `.github/workflows/ios-build.yml`).
2. Chọn Actions → **Build iOS IPA** → **Run workflow**; hoặc push lên nhánh `main`.
3. Khi chạy xong, tải Artifact `FxProCalculator-unsigned-IPA` để lấy `FxProCalculator-unsigned.ipa`.
4. IPA **chưa ký**. Cần ký bằng chứng chỉ/provisioning profile hợp lệ trước khi cài lên iPhone. Sideload tùy theo phương thức và tài khoản thiết bị.

## Build trên Mac
Cài Xcode 16 và XcodeGen: `brew install xcodegen`. Trong thư mục mã nguồn chạy `xcodegen generate` rồi mở `FxProCalculator.xcodeproj`. Chọn team ký ứng dụng nếu muốn chạy trên thiết bị.

## Ghi chú tính toán
- Programmer dùng `UInt64`, cộng/trừ/nhân tự quay vòng ở 64 bit (modulo 2^64); dịch >=64 bit trả về 0. Không hỗ trợ số âm dạng signed tại phiên bản này.
- Các phím toán học nhập biểu thức theo cú pháp có ngoặc; không tự động chèn phép nhân ngầm.
- Đây là máy tính khoa học phổ thông, chưa bao gồm giải phương trình, đạo hàm/tích phân, matrix, thống kê hay phân số kiểu Casio.
