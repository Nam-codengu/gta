# HỆ THỐNG ĐẬP ĐỒ NÂNG CAO CHO OX_INVENTORY (EX/ESX)

## 1. CÀI ĐẶT

- Kéo toàn bộ folder resource này vào thư mục `resources/` của server.
- Thêm vào server.cfg:
  ```
  ensure item-upgrade
  ```
- Yêu cầu server đã cài sẵn **ox_inventory** & **oxmysql**.

## 2. CẤU HÌNH

- Mở file `shared/config.lua` để chỉnh sửa loại vật phẩm, tỉ lệ đập đồ, loại đá, danh hiệu, v.v.

## 3. SỬ DỤNG TÍNH NĂNG

### Đập đồ
- Sử dụng NUI menu để chọn vật phẩm và nâng cấp (hoặc lệnh nếu có).
- Chỉ dùng được đúng loại đá cho mỗi mốc cấp.

### Chuyển/Di truyền cấp
- Chọn 2 vật phẩm cùng loại (nguồn và đích).
- Nút “Di truyền cấp”: chuyển cấp từ vật phẩm nguồn sang vật phẩm đích.

### Tái chế vật phẩm
- Chọn vật phẩm cấp cao cần tái chế.
- Nút “Tái chế”: Nhận lại một phần đá theo cấp.

### Bảng xếp hạng & Danh hiệu
- Nút “Bảng xếp hạng”: Xem top người chơi đập thành công, thánh xui, đại gia may mắn.

### Hiệu ứng đặc biệt
- Khi đập thành công/thất bại, sẽ có hiệu ứng ánh sáng, âm thanh, và thông báo toàn server.

## 4. TUỲ CHỈNH

- Thêm/đổi loại vật phẩm, đá, tỉ lệ, danh hiệu trong `shared/config.lua`.
- Có thể chỉnh HTML/CSS/JS trong thư mục `nui/` để thay đổi giao diện menu nâng cấp.

## 5. LƯU Ý

- Không chỉnh sửa code server nếu không nắm rõ Lua & ox_inventory.
- Khi import lần đầu, database sẽ tự tạo bảng `upgrade_log`.
- Hỗ trợ cả inventory EX/ESX chuẩn của ox_inventory.

---

**Mọi thắc mắc hoặc báo lỗi liên hệ discord: Nam-codengu#xxxx**
