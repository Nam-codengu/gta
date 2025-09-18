# HƯỚNG DẪN HỆ THỐNG NÂNG CẤP BALO

## 📦 GIỚI THIỆU
Hệ thống nâng cấp balo hoàn chỉnh cho FiveM với tích hợp ox_inventory, hỗ trợ 12 cấp độ nâng cấp với quy tắc phức tạp và giao diện hiện đại.

## 🏗️ CẤU TRÚC HỆ THỐNG

### Quy tắc Balo theo Cấp:
- **Cấp 1**: Chỉ có 1 balo mặc định (`balo1`)
- **Cấp 2-12**: Mỗi cấp có 6 balo (3 nam + 3 nữ)
  - Nam: `balo[cấp]nam`, `balo[cấp]nam1`, `balo[cấp]nam2`
  - Nữ: `balo[cấp]nu`, `balo[cấp]nu1`, `balo[cấp]nu2`

### Ví dụ Cấp 5:
- `balo5nam` - Balo Nam Cấp 5 (cơ bản)
- `balo5nam1` - Balo Nam Cấp 5 Phiên bản 1 (+1 slot, +1kg)
- `balo5nam2` - Balo Nam Cấp 5 Phiên bản 2 (+2 slot, +2kg)
- `balo5nu` - Balo Nữ Cấp 5 (cơ bản)
- `balo5nu1` - Balo Nữ Cấp 5 Phiên bản 1 (+1 slot, +1kg)
- `balo5nu2` - Balo Nữ Cấp 5 Phiên bản 2 (+2 slot, +2kg)

## 🔧 CÀI ĐẶT

### Yêu cầu:
- FiveM Server
- ox_inventory
- ox_lib
- oxmysql

### Cài đặt:
1. Sao chép toàn bộ resource vào thư mục `resources/`
2. Thêm vào `server.cfg`:
   ```
   ensure item-upgrade
   ```
3. Khởi động lại server

## ⚙️ CẤU HÌNH

### File cấu hình chính: `shared/config.lua`

```lua
-- Cấu hình tự động sinh balo từ cấp 1-12
Config.Backpacks = {
    [1] = {  -- Cấp 1: Chỉ 1 balo
        {
            name = "balo1",
            label = "Balo Cấp 1",
            level = 1,
            slots = 10,
            maxWeight = 50000,
            upgradeStone = "da_lv1",
            successRate = 85,
            gender = "unisex"
        }
    }
    -- Cấp 2-12 được tự động sinh
}
```

### Đá nâng cấp:
- `da_lv1`: Cấp 1-3
- `da_lv2`: Cấp 4-6  
- `da_lv3`: Cấp 7-9
- `da_lv4`: Cấp 10-12

### Bùa may mắn:
- Cần `bua_may_man` ở cấp: 3, 6, 9, 12

## 🎮 SỬ DỤNG

### Lệnh:
- `/backpack` - Mở menu nâng cấp balo

### Giao diện menu:
1. **Nâng cấp Balo** - Chọn balo và nâng cấp
2. **Di truyền cấp** - Chuyển cấp giữa các balo
3. **Tái chế** - Thu hồi đá từ balo cũ
4. **Bảng xếp hạng** - Xem thống kê người chơi

### Hai phương thức nâng cấp:

#### 1. Nâng cấp Bình thường:
- Thành công: Xóa balo cũ + Thêm balo mới
- Thất bại: Xóa balo cũ (không có balo mới)

#### 2. Đập Balo (Smash):
- Luôn xóa balo cũ trước
- Thành công: Nhận balo mới ngẫu nhiên cùng cấp kế tiếp
- Thất bại: Mất hoàn toàn balo

## 🔍 KIỂM TRA VÀ XÁC THỰC

### Hệ thống kiểm tra:
- ✅ Đúng loại balo (phải là balo hợp lệ)
- ✅ Đúng thứ tự cấp (chỉ nâng lên cấp kế tiếp)
- ✅ Tương thích giới tính (nam/nữ/unisex)
- ✅ Đủ đá nâng cấp
- ✅ Đủ bùa may mắn (nếu cần)
- ✅ Cấp tối đa (không vượt quá cấp 12)

## 📊 THỐNG KÊ & TỶ LỆ

### Tỷ lệ thành công theo cấp:
- Cấp 1→2: 85%
- Cấp 2→3: 80%
- Cấp 3→4: 75%
- ...giảm dần...
- Cấp 11→12: 30%

### Thông số balo:
- **Slots**: Tăng 2 ô/cấp (cơ bản)
- **Weight**: Tăng 5kg/cấp (cơ bản)
- **Phiên bản 1**: +1 slot, +1kg
- **Phiên bản 2**: +2 slot, +2kg

## 🛠️ API CHO DEVELOPERS

### Server Exports:
```lua
-- Lấy thông tin balo
local config = exports['item-upgrade']:getBackpackConfig('balo5nam')

-- Lấy tùy chọn nâng cấp
local options = exports['item-upgrade']:getUpgradeOptions('balo5nam')

-- Nâng cấp balo
exports['item-upgrade']:upgradeBackpack(source, slot, 'balo6nam')

-- Đập balo
exports['item-upgrade']:smashBackpack(source, slot)
```

### Client Exports:
```lua
-- Mở menu balo
exports['item-upgrade']:openBackpackMenu()
```

## 🐛 TROUBLESHOOTING

### Lỗi thường gặp:

1. **"Không tìm thấy balo"**
   - Kiểm tra item có trong inventory
   - Xác nhận tên balo đúng định dạng

2. **"Không đủ đá nâng cấp"**
   - Kiểm tra có đủ đá đúng loại
   - Xem bảng yêu cầu đá theo cấp

3. **"Cần bùa may mắn"**
   - Cần `bua_may_man` ở cấp 3, 6, 9, 12
   - Kiểm tra inventory có item này

4. **Menu không hiển thị**
   - Kiểm tra ox_lib đã cài đặt
   - Xem console log lỗi

## 📝 LOG & TRACKING

Hệ thống tự động log:
- Thành công/thất bại nâng cấp
- Thông tin người chơi
- Thời gian thực hiện
- Cấp độ đạt được

Bảng database: `upgrade_log`

## 🎯 TÍNH NĂNG NỔI BẬT

- ✨ Giao diện NUI hiện đại, responsive
- 🔄 Hệ thống nâng cấp thông minh
- 🎲 Đập balo với yếu tố may rủi
- 📈 Tracking và ranking người chơi
- 🔗 Tích hợp sâu với ox_inventory
- 🎵 Hiệu ứng âm thanh và thị giác
- 🌐 Hỗ trợ đa ngôn ngữ (Tiếng Việt)
- 🔒 Bảo mật và kiểm tra nghiêm ngặt

## 👨‍💻 HỖ TRỢ

Liên hệ:
- Discord: Nam-codengu#xxxx
- GitHub: https://github.com/Nam-codengu/gta

---
**Phiên bản**: 2.0.0  
**Cập nhật**: Hệ thống balo hoàn chỉnh với 12 cấp độ  
**Tương thích**: FiveM, ox_inventory, EX/ESX