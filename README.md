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

### Cấu hình vật phẩm nâng cấp:
Mỗi vật phẩm trong `Config.UpgradeItems` có thể cấu hình:
- `label`: Tên hiển thị của vật phẩm
- `icon`: (Tùy chọn) Tên file icon trong `/nui/icons/` (ví dụ: "backpack.png")  
- `maxLevel`: Cấp tối đa
- `upgradeStones`: Loại đá nâng cấp cho mỗi cấp
- `rates`: Tỉ lệ thành công cho mỗi cấp (%)
- `requireTalismanAt`: Các cấp yêu cầu bùa may mắn

### Cấu hình icon:
- Đặt file icon (.png) vào thư mục `/nui/icons/`
- Kích thước khuyến nghị: 32x32 pixel trở lên
- Nếu không có icon, chỉ hiển thị tên vật phẩm

## 3. SỬ DỤNG TÍNH NĂNG

### Mở menu nâng cấp
- Sử dụng lệnh `/upgrade` hoặc phím `F7` để mở menu nâng cấp
- Menu sẽ hiển thị danh sách tất cả vật phẩm có thể nâng cấp từ config

### Danh sách vật phẩm nâng cấp
- Hiển thị tất cả vật phẩm trong `Config.UpgradeItems`
- Mỗi vật phẩm hiển thị: tên, icon (nếu có), và cấp tối đa
- Danh sách có thể cuộn nếu có nhiều vật phẩm

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
