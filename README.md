# HỆ THỐNG ĐẬP ĐỒ NÂNG CAO CHO OX_INVENTORY (EX/ESX)

## 🎒 **HỆ THỐNG BALO MỚI - CẬP NHẬT 2.0**

### ✨ Tính năng mới:
- **Hệ thống balo 12 cấp hoàn chỉnh** với quy tắc phức tạp
- **Đập balo (Smash)** - Phiên bản rủi ro cao
- **Giao diện NUI hiện đại** với responsive design
- **67 loại balo khác nhau** (1 cấp 1 + 66 cấp 2-12)
- **Phân loại giới tính** nam/nữ với 3 phiên bản mỗi cấp

### 📋 Quy tắc Balo:
- **Cấp 1**: 1 balo mặc định (`balo1`)
- **Cấp 2-12**: Mỗi cấp có 6 balo:
  - 3 balo nam: `balo[cấp]nam`, `balo[cấp]nam1`, `balo[cấp]nam2`  
  - 3 balo nữ: `balo[cấp]nu`, `balo[cấp]nu1`, `balo[cấp]nu2`

---

## 1. CÀI ĐẶT

- Kéo toàn bộ folder resource này vào thư mục `resources/` của server.
- Thêm vào server.cfg:
  ```
  ensure item-upgrade
  ```
- Yêu cầu server đã cài sẵn **ox_inventory** & **oxmysql**.

## 2. CẤU HÌNH

- Mở file `shared/config.lua` để chỉnh sửa hệ thống balo.
- Xem `config_sample.lua` để hiểu cấu trúc.
- Import `ox_inventory_items.lua` vào ox_inventory để thêm items.

## 3. SỬ DỤNG TÍNH NĂNG

### 🎒 Nâng cấp Balo
- Lệnh: `/backpack` để mở menu
- Chọn balo và phương thức nâng cấp:
  - **Nâng cấp bình thường**: An toàn hơn
  - **Đập balo**: Rủi ro cao, luôn mất balo cũ

### Đập đồ (Legacy)
- Sử dụng NUI menu để chọn vật phẩm và nâng cấp.
- Chỉ dùng được đúng loại đá cho mỗi mốc cấp.

### Chuyển/Di truyền cấp
- Chọn 2 vật phẩm cùng loại (nguồn và đích).
- Nút "Di truyền cấp": chuyển cấp từ vật phẩm nguồn sang vật phẩm đích.

### Tái chế vật phẩm
- Chọn vật phẩm cấp cao cần tái chế.
- Nút "Tái chế": Nhận lại một phần đá theo cấp.

### Bảng xếp hạng & Danh hiệu
- Nút "Bảng xếp hạng": Xem top người chơi đập thành công, thánh xui, đại gia may mắn.

### Hiệu ứng đặc biệt
- Khi đập thành công/thất bại, sẽ có hiệu ứng ánh sáng, âm thanh, và thông báo toàn server.

## 4. TUỲ CHỈNH

- Thêm/đổi loại balo, đá, tỉ lệ trong `shared/config.lua`.
- Xem `BACKPACK_GUIDE.md` để hiểu chi tiết hệ thống.
- Có thể chỉnh HTML/CSS/JS trong thư mục `nui/` để thay đổi giao diện menu nâng cấp.

## 5. LƯU Ý

- Không chỉnh sửa code server nếu không nắm rõ Lua & ox_inventory.
- Khi import lần đầu, database sẽ tự tạo bảng `upgrade_log`.
- Hỗ trợ cả inventory EX/ESX chuẩn của ox_inventory.
- **Hệ thống balo yêu cầu đá nâng cấp và bùa may mắn theo cấp**.

## 6. FILES QUAN TRỌNG

- `shared/config.lua` - Cấu hình chính
- `backpack_upgrade.lua` - Module nâng cấp balo
- `config_sample.lua` - Mẫu cấu hình chi tiết
- `ox_inventory_items.lua` - Định nghĩa items cho ox_inventory
- `BACKPACK_GUIDE.md` - Hướng dẫn chi tiết
- `test_backpack_system.lua` - Script kiểm tra hệ thống

---

**Mọi thắc mắc hoặc báo lỗi liên hệ discord: Nam-codengu#xxxx**