# HỆ THỐNG NÂNG CẤP BALO - UPGRADE_BACKPACK

## Mô tả
Resource upgrade_backpack cung cấp hệ thống nâng cấp balo/vật phẩm với giao diện NUI chia tab hiện đại, được thiết kế để tích hợp với ox_inventory và có thể mở rộng dễ dàng.

## Tính năng chính

### 🎯 NUI chia 4 tab:
1. **Đập đồ** - Nâng cấp vật phẩm với tỷ lệ thành công khác nhau
2. **Di truyền cấp** - Chuyển cấp độ giữa các vật phẩm cùng loại
3. **Tái chế** - Tái chế vật phẩm để nhận lại nguyên liệu
4. **BXH** - Bảng xếp hạng và danh hiệu đặc biệt

### 🔧 Tính năng kỹ thuật:
- Hỗ trợ đầy đủ ox_inventory
- Database logging cho ranking system
- Callback system giữa client-server-web
- Responsive design cho mọi kích thước màn hình
- Effect system với particle effects
- Sound system
- Notification system

## Cài đặt

1. Copy folder `upgrade_backpack` vào thư mục `resources/` của server
2. Thêm vào `server.cfg`:
   ```
   ensure upgrade_backpack
   ```
3. Yêu cầu: **ox_inventory**, **oxmysql**, **ox_lib**

## Cấu hình

### File config chính: `shared/config_backpacks.lua`

```lua
Config.UpgradeItems = {
    backpack = {
        label = "Balo",
        maxLevel = 15,
        slotPerLevel = 3,
        weightPerLevel = 15,
        -- ... thêm cấu hình
    }
}
```

### Tùy chỉnh NUI:
- `web/build/style.css` - Giao diện
- `web/build/app.js` - Logic frontend
- `web/build/index.html` - Cấu trúc HTML

## Sử dụng

### Mở NUI:
- Phím tắt: `F6`
- Command: `/upgrade_backpack`
- Export: `exports.upgrade_backpack:openUpgradeNUI()`

### API Callbacks:

#### Server callbacks:
```lua
-- Lấy ranking
lib.callback.register('upgrade_backpack:getRanking', function(source)
    -- Trả về dữ liệu ranking
end)

-- Nâng cấp vật phẩm
lib.callback.register('upgrade_backpack:upgradeItem', function(source, slot, itemName)
    -- Logic nâng cấp
end)

-- Lấy inventory
lib.callback.register('upgrade_backpack:getInventory', function(source)
    -- Trả về danh sách vật phẩm có thể nâng cấp
end)
```

#### Client events:
```lua
-- Hiệu ứng
RegisterNetEvent('upgrade_backpack:effect', function(effectType, level, playerName, itemName)
    -- Xử lý hiệu ứng
end)

-- Mở NUI từ server
RegisterNetEvent('upgrade_backpack:showNUI', function()
    openUpgradeNUI()
end)
```

#### NUI callbacks:
```javascript
// Đóng NUI
RegisterNUICallback('closeNUI', function(data, cb) end)

// Nâng cấp vật phẩm
RegisterNUICallback('upgradeItem', function(data, cb) end)

// Di truyền cấp
RegisterNUICallback('transferLevel', function(data, cb) end)

// Tái chế
RegisterNUICallback('recycleItem', function(data, cb) end)

// Lấy BXH
RegisterNUICallback('getRanking', function(data, cb) end)
```

## Tích hợp ox_inventory

Resource sử dụng đầy đủ ox_inventory API:
- `ox_inventory:GetPlayer()`
- `ox_inventory:AddItem()`
- `ox_inventory:RemoveItem()`
- `ox_inventory:SetMetadata()`
- `ox_inventory:Search()`

## Database Schema

```sql
CREATE TABLE backpack_upgrade_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    identifier VARCHAR(64),
    name VARCHAR(64),
    item VARCHAR(32),
    level INT,
    status VARCHAR(16),
    action_type VARCHAR(16),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

## Mở rộng

### Thêm vật phẩm mới:
1. Cập nhật `Config.UpgradeItems` trong `shared/config_backpacks.lua`
2. Thêm logic xử lý trong `server/main.lua` nếu cần

### Thêm hiệu ứng mới:
1. Cập nhật `Config.Effects` trong config
2. Thêm xử lý trong `client/main.lua`

### Tùy chỉnh NUI:
1. Chỉnh sửa HTML/CSS/JS trong `web/build/`
2. Thêm callback mới nếu cần

## Exports

```lua
-- Mở NUI
exports.upgrade_backpack:openUpgradeNUI()

-- Đóng NUI
exports.upgrade_backpack:closeUpgradeNUI()

-- Kiểm tra NUI có đang mở
local isOpen = exports.upgrade_backpack:isNUIOpen()
```

## Lưu ý quan trọng

1. **Database**: Tự động tạo bảng khi khởi động lần đầu
2. **Performance**: Sử dụng callback thay vì trigger events để tối ưu
3. **Security**: Validate dữ liệu từ client trước khi xử lý
4. **Compatibility**: Đã test với ox_inventory phiên bản mới nhất

## Troubleshooting

### Lỗi thường gặp:
1. **NUI không hiển thị**: Kiểm tra file path trong fxmanifest.lua
2. **Database error**: Đảm bảo oxmysql đã load trước resource
3. **Inventory không load**: Kiểm tra ox_inventory đã start

### Debug:
- Check console cho error messages
- Verify resource dependencies
- Test từng callback riêng lẻ

---

**Developed by Nam-codengu for GTA V FiveM servers**