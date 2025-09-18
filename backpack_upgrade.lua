-- ==================================================================
-- BACKPACK UPGRADE SYSTEM (LUA)
-- Hệ thống nâng cấp và đập balo hoàn chỉnh
-- ==================================================================

--[[
    TÍNH NĂNG CHÍNH:
    1. Nâng cấp balo từ cấp 1 đến cấp 12
    2. Đập balo (smash): Thành công = xóa cũ + thêm mới, Thất bại = chỉ xóa cũ
    3. Kiểm tra đúng loại balo, đúng thứ tự cấp
    4. Kiểm tra đủ đá nâng cấp và bùa may mắn
    5. Tích hợp ox_inventory
    6. Hệ thống log và ranking
    
    CÁCH SỬ DỤNG:
    - Lệnh: /backpack (mở menu nâng cấp)
    - API: exports['item-upgrade']:openBackpackMenu()
]]

BackpackUpgrade = {}

-- Initialize the backpack upgrade system
function BackpackUpgrade:Init()
    print("[BACKPACK UPGRADE] Khởi tạo hệ thống nâng cấp balo...")
    
    -- Validate configuration
    if not Config.Backpacks then
        print("[BACKPACK UPGRADE] CẢNH BÁO: Không tìm thấy cấu hình balo!")
        return false
    end
    
    -- Register events and callbacks
    self:RegisterEvents()
    
    -- Create backpack lookup table if not exists
    if not Config.BackpackLookup then
        self:CreateLookupTable()
    end
    
    print("[BACKPACK UPGRADE] Hệ thống đã sẵn sàng!")
    return true
end

-- Create lookup table for quick backpack access
function BackpackUpgrade:CreateLookupTable()
    Config.BackpackLookup = {}
    for level, backpacks in pairs(Config.Backpacks) do
        for _, backpack in pairs(backpacks) do
            Config.BackpackLookup[backpack.name] = backpack
        end
    end
end

-- Register all events (Server-side)
function BackpackUpgrade:RegisterEvents()
    if IsDuplicityVersion() then -- Server-side only
        -- Main upgrade event
        RegisterNetEvent('backpack:upgrade', function(slot, targetBackpackName)
            self:HandleUpgrade(source, slot, targetBackpackName)
        end)
        
        -- Smash upgrade event
        RegisterNetEvent('backpack:smash', function(slot)
            self:HandleSmash(source, slot)
        end)
        
        -- Get available upgrades for a backpack
        lib.callback.register('backpack:getUpgradeOptions', function(source, backpackName)
            return self:GetUpgradeOptions(backpackName)
        end)
        
        -- Get player backpacks
        lib.callback.register('backpack:getPlayerBackpacks', function(source)
            return self:GetPlayerBackpacks(source)
        end)
    end
end

-- Get upgrade options for a backpack
function BackpackUpgrade:GetUpgradeOptions(backpackName)
    local backpack = Config.BackpackLookup[backpackName]
    if not backpack or backpack.level >= 12 then
        return {}
    end
    
    local nextLevel = backpack.level + 1
    local nextBackpacks = Config.Backpacks[nextLevel]
    
    if not nextBackpacks then
        return {}
    end
    
    -- Filter by gender compatibility
    local options = {}
    for _, nextBackpack in pairs(nextBackpacks) do
        if backpack.gender == "unisex" or 
           nextBackpack.gender == backpack.gender or 
           nextBackpack.gender == "unisex" then
            table.insert(options, nextBackpack)
        end
    end
    
    return options
end

-- Get all backpacks in player inventory
function BackpackUpgrade:GetPlayerBackpacks(source)
    local ox_inventory = exports.ox_inventory
    local player = ox_inventory:GetPlayer(source)
    if not player or not player.inventory then
        return {}
    end
    
    local backpacks = {}
    for slot, item in pairs(player.inventory) do
        if item and Config.BackpackLookup[item.name] then
            table.insert(backpacks, {
                slot = slot,
                item = item,
                config = Config.BackpackLookup[item.name]
            })
        end
    end
    
    return backpacks
end

-- Handle backpack upgrade
function BackpackUpgrade:HandleUpgrade(source, slot, targetBackpackName)
    local ox_inventory = exports.ox_inventory
    local player = ox_inventory:GetPlayer(source)
    
    if not player or not player.inventory then
        self:NotifyPlayer(source, 'Không thể truy cập inventory!', 'error')
        return
    end
    
    local item = player.inventory[slot]
    if not item then
        self:NotifyPlayer(source, 'Không tìm thấy balo!', 'error')
        return
    end
    
    local currentBackpack = Config.BackpackLookup[item.name]
    if not currentBackpack then
        self:NotifyPlayer(source, 'Vật phẩm này không phải balo!', 'error')
        return
    end
    
    local targetBackpack = Config.BackpackLookup[targetBackpackName]
    if not targetBackpack then
        self:NotifyPlayer(source, 'Balo đích không hợp lệ!', 'error')
        return
    end
    
    -- Validate upgrade progression
    if not self:ValidateUpgrade(source, currentBackpack, targetBackpack) then
        return
    end
    
    -- Check and consume requirements
    if not self:CheckAndConsumeRequirements(source, targetBackpack) then
        return
    end
    
    -- Perform upgrade
    self:PerformUpgrade(source, slot, item, currentBackpack, targetBackpack, false)
end

-- Handle backpack smash
function BackpackUpgrade:HandleSmash(source, slot)
    local ox_inventory = exports.ox_inventory
    local player = ox_inventory:GetPlayer(source)
    
    if not player or not player.inventory then
        self:NotifyPlayer(source, 'Không thể truy cập inventory!', 'error')
        return
    end
    
    local item = player.inventory[slot]
    if not item then
        self:NotifyPlayer(source, 'Không tìm thấy balo!', 'error')
        return
    end
    
    local currentBackpack = Config.BackpackLookup[item.name]
    if not currentBackpack then
        self:NotifyPlayer(source, 'Vật phẩm này không phải balo!', 'error')
        return
    end
    
    if currentBackpack.level >= 12 then
        self:NotifyPlayer(source, 'Balo đã ở cấp tối đa!', 'error')
        return
    end
    
    -- Get random next level backpack
    local upgradeOptions = self:GetUpgradeOptions(item.name)
    if #upgradeOptions == 0 then
        self:NotifyPlayer(source, 'Không có balo cấp cao hơn!', 'error')
        return
    end
    
    local targetBackpack = upgradeOptions[math.random(#upgradeOptions)]
    
    -- Check and consume requirements
    if not self:CheckAndConsumeRequirements(source, targetBackpack) then
        return
    end
    
    -- Perform smash (always remove old backpack first)
    self:PerformUpgrade(source, slot, item, currentBackpack, targetBackpack, true)
end

-- Validate if upgrade is allowed
function BackpackUpgrade:ValidateUpgrade(source, currentBackpack, targetBackpack)
    -- Check if target is next level
    if targetBackpack.level ~= currentBackpack.level + 1 then
        self:NotifyPlayer(source, 'Chỉ có thể nâng cấp lên cấp kế tiếp!', 'error')
        return false
    end
    
    -- Check gender compatibility
    if currentBackpack.gender ~= "unisex" and targetBackpack.gender ~= "unisex" and 
       currentBackpack.gender ~= targetBackpack.gender then
        self:NotifyPlayer(source, 'Không thể chuyển đổi giới tính balo!', 'error')
        return false
    end
    
    return true
end

-- Check and consume upgrade requirements
function BackpackUpgrade:CheckAndConsumeRequirements(source, targetBackpack)
    local ox_inventory = exports.ox_inventory
    
    -- Check upgrade stone
    local requiredStone = targetBackpack.upgradeStone
    local stoneAmount = Config.UpgradeRequirements.stoneAmount or 1
    local stoneCount = ox_inventory:GetItem(source, requiredStone, nil, true)
    
    if not stoneCount or stoneCount < stoneAmount then
        self:NotifyPlayer(source, 'Không đủ đá nâng cấp ' .. requiredStone .. '!', 'error')
        return false
    end
    
    -- Check talisman requirement
    local requiresTalisman = false
    for _, level in pairs(Config.UpgradeRequirements.requireTalisman or {}) do
        if targetBackpack.level == level then
            requiresTalisman = true
            break
        end
    end
    
    if requiresTalisman then
        local talismanItem = Config.UpgradeRequirements.talismanItem or "bua_may_man"
        local talismanCount = ox_inventory:GetItem(source, talismanItem, nil, true)
        if not talismanCount or talismanCount < 1 then
            self:NotifyPlayer(source, 'Cần bùa may mắn để nâng cấp cấp này!', 'error')
            return false
        end
        
        -- Consume talisman
        ox_inventory:RemoveItem(source, talismanItem, 1)
    end
    
    -- Consume upgrade stone
    ox_inventory:RemoveItem(source, requiredStone, stoneAmount)
    
    return true
end

-- Perform the actual upgrade
function BackpackUpgrade:PerformUpgrade(source, slot, item, currentBackpack, targetBackpack, isSmash)
    local ox_inventory = exports.ox_inventory
    local successChance = targetBackpack.successRate or 50
    local isSuccess = math.random(100) <= successChance
    
    local playerName = GetPlayerName(source) or "Unknown"
    local playerIdentifier = self:GetPlayerIdentifier(source)
    
    if isSmash then
        -- Smash: Always remove old backpack first
        ox_inventory:RemoveItem(source, item.name, 1, nil, slot)
    end
    
    if isSuccess then
        -- Success: Add new backpack
        if not isSmash then
            -- Normal upgrade: remove old backpack
            ox_inventory:RemoveItem(source, item.name, 1, nil, slot)
        end
        
        local newItem = ox_inventory:AddItem(source, targetBackpack.name, 1)
        if newItem then
            -- Set metadata for new backpack
            local metadata = {
                level = targetBackpack.level,
                label = targetBackpack.label,
                upgraded = true,
                upgradeDate = os.time()
            }
            ox_inventory:SetMetadata(source, newItem.slot, metadata)
            
            local upgradeType = isSmash and "Đập balo" or "Nâng cấp"
            self:NotifyPlayer(source, upgradeType .. ' thành công! Nhận được ' .. targetBackpack.label, 'success')
            
            -- Log success
            self:LogUpgrade(playerIdentifier, playerName, targetBackpack.name, targetBackpack.level, 'success')
            
            -- Trigger effects
            TriggerClientEvent('upgrade:effect', source, 'success', playerName, targetBackpack.label, targetBackpack.level)
            TriggerClientEvent('upgrade:effect', -1, 'success', playerName, targetBackpack.label, targetBackpack.level)
        else
            self:NotifyPlayer(source, 'Lỗi khi thêm balo mới!', 'error')
        end
    else
        -- Failure
        if not isSmash then
            -- Normal upgrade: remove old backpack on failure
            ox_inventory:RemoveItem(source, item.name, 1, nil, slot)
        end
        
        local upgradeType = isSmash and "Đập balo" or "Nâng cấp"
        self:NotifyPlayer(source, upgradeType .. ' thất bại! Balo đã bị phá hủy.', 'error')
        
        -- Log failure
        self:LogUpgrade(playerIdentifier, playerName, item.name, currentBackpack.level, 'fail')
        
        -- Trigger effects
        TriggerClientEvent('upgrade:effect', source, 'fail', playerName, currentBackpack.label, currentBackpack.level)
        TriggerClientEvent('upgrade:effect', -1, 'fail', playerName, currentBackpack.label, currentBackpack.level)
    end
end

-- Helper functions
function BackpackUpgrade:GetPlayerIdentifier(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, id in pairs(identifiers) do
        if string.find(id, "license:") then
            return id
        end
    end
    return "unknown"
end

function BackpackUpgrade:NotifyPlayer(source, message, type)
    TriggerClientEvent('ox_lib:notify', source, {
        description = message,
        type = type or 'inform'
    })
end

function BackpackUpgrade:LogUpgrade(identifier, name, item, level, status)
    TriggerEvent('upgrade:log', {
        identifier = identifier,
        name = name,
        item = item,
        level = level,
        status = status
    })
end

-- Export system for other resources
if IsDuplicityVersion() then
    -- Server exports
    exports('getBackpackConfig', function(backpackName)
        return Config.BackpackLookup[backpackName]
    end)
    
    exports('getUpgradeOptions', function(backpackName)
        return BackpackUpgrade:GetUpgradeOptions(backpackName)
    end)
    
    exports('upgradeBackpack', function(source, slot, targetBackpack)
        BackpackUpgrade:HandleUpgrade(source, slot, targetBackpack)
    end)
    
    exports('smashBackpack', function(source, slot)
        BackpackUpgrade:HandleSmash(source, slot)
    end)
else
    -- Client exports
    exports('openBackpackMenu', function()
        TriggerEvent('backpack:openUpgradeMenu')
    end)
end

-- Initialize the system
if IsDuplicityVersion() then
    Citizen.CreateThread(function()
        Wait(1000) -- Wait for config to load
        BackpackUpgrade:Init()
    end)
end

-- Return the module
return BackpackUpgrade