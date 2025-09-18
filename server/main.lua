local ox_inventory = exports.ox_inventory

MySQL.ready(function()
    MySQL.query([[ 
        CREATE TABLE IF NOT EXISTS backpack_upgrade_log (
            id INT AUTO_INCREMENT PRIMARY KEY,
            identifier VARCHAR(64),
            name VARCHAR(64),
            backpack_type VARCHAR(32),
            from_level INT,
            to_level INT,
            status VARCHAR(16),
            timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]])
end)

-- Log backpack upgrade attempts
local function LogUpgrade(src, backpackType, fromLevel, toLevel, status)
    local player = ox_inventory:GetPlayer(src)
    if not player then return end
    
    MySQL.insert('INSERT INTO backpack_upgrade_log (identifier, name, backpack_type, from_level, to_level, status) VALUES (?, ?, ?, ?, ?, ?)', {
        player.identifier, player.name or 'Unknown', backpackType, fromLevel, toLevel, status
    })
end

-- Backpack upgrade event
RegisterNetEvent('backpack:upgrade', function(slot)
    local src = source
    local player = ox_inventory:GetPlayer(src)
    local inv = player and player.inventory
    
    if not inv then 
        TriggerClientEvent('ox_lib:notify', src, {description = 'Lỗi inventory!', type = 'error'})
        return 
    end
    
    local item = inv[slot]
    if not item then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Không tìm thấy balo!', type = 'error'})
        return
    end
    
    local backpackInfo = ConfigBackpacks.GetBackpackInfo(item.name)
    if not backpackInfo then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Vật phẩm không phải balo!', type = 'error'})
        return
    end
    
    if backpackInfo.level >= 5 then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Balo đã đạt cấp tối đa!', type = 'error'})
        return
    end
    
    -- Check for required stone
    local requiredStone = ConfigBackpacks.GetRequiredStone(backpackInfo.level)
    local stoneCount = ox_inventory:GetItem(src, requiredStone, nil, true)
    
    if not stoneCount or stoneCount < 1 then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Không có đá nâng cấp cần thiết!', type = 'error'})
        return
    end
    
    -- Remove the stone
    if not ox_inventory:RemoveItem(src, requiredStone, 1) then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Không thể sử dụng đá nâng cấp!', type = 'error'})
        return
    end
    
    -- Get success rate and roll for success
    local successRate = ConfigBackpacks.GetUpgradeRate(backpackInfo.level)
    local roll = math.random(1, 100)
    local success = roll <= successRate
    
    if success then
        -- Upgrade successful
        local nextLevelBackpack = ConfigBackpacks.GetNextLevelBackpack(item.name)
        if nextLevelBackpack then
            -- Remove old backpack and add new one
            ox_inventory:RemoveItem(src, item.name, 1, item.metadata, slot)
            ox_inventory:AddItem(src, nextLevelBackpack, 1, item.metadata)
            
            local newLevel = backpackInfo.level + 1
            LogUpgrade(src, item.name, backpackInfo.level, newLevel, 'success')
            TriggerClientEvent('backpack:upgradeResult', src, true, nextLevelBackpack, newLevel)
            
            -- Notify all players about successful upgrade
            TriggerClientEvent('ox_lib:notify', -1, {
                description = string.format('%s đã nâng cấp balo thành công lên cấp %d!', player.name or 'Ai đó', newLevel),
                type = 'inform',
                duration = 3000
            })
        end
    else
        -- Upgrade failed - destroy the backpack
        ox_inventory:RemoveItem(src, item.name, 1, item.metadata, slot)
        LogUpgrade(src, item.name, backpackInfo.level, backpackInfo.level + 1, 'fail')
        TriggerClientEvent('backpack:upgradeResult', src, false, nil, backpackInfo.level + 1)
        
        -- Notify all players about failed upgrade
        TriggerClientEvent('ox_lib:notify', -1, {
            description = string.format('%s đã nâng cấp balo thất bại và mất balo!', player.name or 'Ai đó'),
            type = 'warning',
            duration = 3000
        })
    end
end)

-- Transfer level between backpacks
RegisterNetEvent('backpack:transfer', function(sourceSlot, targetSlot)
    local src = source
    local player = ox_inventory:GetPlayer(src)
    local inv = player and player.inventory
    
    if not inv then return end
    
    local sourceItem = inv[sourceSlot]
    local targetItem = inv[targetSlot]
    
    if not sourceItem or not targetItem then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Hai vật phẩm không hợp lệ!', type = 'error'})
        TriggerClientEvent('backpack:transferResult', src, false)
        return
    end
    
    local sourceInfo = ConfigBackpacks.GetBackpackInfo(sourceItem.name)
    local targetInfo = ConfigBackpacks.GetBackpackInfo(targetItem.name)
    
    if not sourceInfo or not targetInfo then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Hai vật phẩm phải là balo!', type = 'error'})
        TriggerClientEvent('backpack:transferResult', src, false)
        return
    end
    
    if not ConfigBackpacks.IsSameType(sourceItem.name, targetItem.name) then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Hai balo phải cùng loại!', type = 'error'})
        TriggerClientEvent('backpack:transferResult', src, false)
        return
    end
    
    if sourceInfo.level <= targetInfo.level then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Balo nguồn phải có cấp cao hơn!', type = 'error'})
        TriggerClientEvent('backpack:transferResult', src, false)
        return
    end
    
    -- Transfer level (with 10% chance of level reduction)
    local transferLevel = sourceInfo.level
    if math.random(100) <= 10 then
        transferLevel = transferLevel - 1
    end
    
    -- Find the correct target backpack name for the new level
    local newTargetBackpack = string.format('backpack_%s%d_lv%d', 
        targetInfo.gender == 'male' and 'm' or 'f',
        targetInfo.variant,
        transferLevel
    )
    
    -- Remove both items and add the upgraded target
    ox_inventory:RemoveItem(src, sourceItem.name, 1, sourceItem.metadata, sourceSlot)
    ox_inventory:RemoveItem(src, targetItem.name, 1, targetItem.metadata, targetSlot)
    ox_inventory:AddItem(src, newTargetBackpack, 1, targetItem.metadata)
    
    TriggerClientEvent('backpack:transferResult', src, true)
    TriggerClientEvent('ox_lib:notify', src, {description = string.format('Di truyền thành công! Cấp mới: %d', transferLevel), type = 'success'})
end)

-- Recycle backpack for stones
RegisterNetEvent('backpack:recycle', function(slot)
    local src = source
    local player = ox_inventory:GetPlayer(src)
    local inv = player and player.inventory
    
    if not inv then return end
    
    local item = inv[slot]
    if not item then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Không tìm thấy balo!', type = 'error'})
        TriggerClientEvent('backpack:recycleResult', src, false, 0)
        return
    end
    
    local backpackInfo = ConfigBackpacks.GetBackpackInfo(item.name)
    if not backpackInfo or backpackInfo.level <= 1 then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Chỉ có thể tái chế balo cấp 2 trở lên!', type = 'error'})
        TriggerClientEvent('backpack:recycleResult', src, false, 0)
        return
    end
    
    -- Calculate stones to return (50% of stones used to reach this level)
    local totalStones = 0
    for i = 1, backpackInfo.level - 1 do
        totalStones = totalStones + 1
    end
    local returnStones = math.floor(totalStones * 0.5)
    
    if returnStones <= 0 then returnStones = 1 end
    
    -- Remove backpack and give stones
    ox_inventory:RemoveItem(src, item.name, 1, item.metadata, slot)
    
    -- Give different types of stones based on level
    if backpackInfo.level >= 4 then
        ox_inventory:AddItem(src, 'da_nang_cap_3', returnStones)
    elseif backpackInfo.level >= 3 then
        ox_inventory:AddItem(src, 'da_nang_cap_2', returnStones)
    else
        ox_inventory:AddItem(src, 'da_nang_cap_1', returnStones)
    end
    
    TriggerClientEvent('backpack:recycleResult', src, true, returnStones)
    TriggerClientEvent('ox_lib:notify', src, {description = string.format('Tái chế thành công! Nhận được %d đá', returnStones), type = 'success'})
end)

-- Get rankings
RegisterNetEvent('backpack:getRankings', function()
    local src = source
    
    -- Top successful upgrades
    local topSuccess = MySQL.query.await([[
        SELECT name, MAX(to_level) as max_level, COUNT(*) as total_upgrades 
        FROM backpack_upgrade_log 
        WHERE status = 'success' 
        GROUP BY identifier 
        ORDER BY max_level DESC, total_upgrades DESC 
        LIMIT 10
    ]])
    
    -- Most failures (unlucky)
    local mostFails = MySQL.query.await([[
        SELECT name, COUNT(*) as fail_count 
        FROM backpack_upgrade_log 
        WHERE status = 'fail' 
        GROUP BY identifier 
        ORDER BY fail_count DESC 
        LIMIT 1
    ]])
    
    -- Most successful upgrades (lucky)
    local mostSuccess = MySQL.query.await([[
        SELECT name, COUNT(*) as success_count 
        FROM backpack_upgrade_log 
        WHERE status = 'success' 
        GROUP BY identifier 
        ORDER BY success_count DESC 
        LIMIT 1
    ]])
    
    local rankings = {
        top = topSuccess or {},
        unlucky = mostFails[1] or nil,
        lucky = mostSuccess[1] or nil
    }
    
    TriggerClientEvent('backpack:rankingsResult', src, rankings)
end)

-- Keep existing upgrade system events for compatibility
RegisterNetEvent('upgrade:log', function(data)
    MySQL.insert('INSERT INTO upgrade_log (identifier, name, item, level, status) VALUES (?, ?, ?, ?, ?)', {
        data.identifier, data.name, data.item, data.level, data.status
    })
end)

lib.callback.register('upgrade:getRank', function()
    local top = MySQL.query.await('SELECT name, MAX(level) as level FROM upgrade_log WHERE status="success" GROUP BY identifier ORDER BY level DESC LIMIT 10')
    local unlucky = MySQL.query.await('SELECT name, COUNT(*) as fail FROM upgrade_log WHERE status="fail" GROUP BY identifier ORDER BY fail DESC LIMIT 1')
    local lucky = MySQL.query.await('SELECT name, COUNT(*) as success FROM upgrade_log WHERE status="success" GROUP BY identifier ORDER BY success DESC LIMIT 1')
    return {top = top, unlucky = unlucky[1], lucky = lucky[1]}
end)

RegisterNetEvent('upgrade:transfer', function(srcSlot, dstSlot)
    local src = source
    local player = ox_inventory:GetPlayer(src)
    local inv = player and player.inventory
    if not inv then return end
    local itemSrc = inv[srcSlot]
    local itemDst = inv[dstSlot]
    if not itemSrc or not itemDst or itemSrc.name ~= itemDst.name then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Hai vật phẩm không hợp lệ!', type = 'error'})
        return
    end
    local level = itemSrc.metadata.level or 1
    if level <= (itemDst.metadata.level or 1) then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Cấp nguồn phải cao hơn!', type = 'error'})
        return
    end
    local transferLevel = level
    if math.random(100) < 10 then transferLevel = level - 1 end
    itemDst.metadata.level = transferLevel
    ox_inventory:SetMetadata(src, dstSlot, itemDst.metadata)
    ox_inventory:RemoveItem(src, itemSrc.name, 1, nil, srcSlot)
    TriggerClientEvent('ox_lib:notify', src, {description = 'Di truyền cấp thành công!', type = 'success'})
    TriggerClientEvent('upgrade:effect', src, 'transfer')
end)

RegisterNetEvent('upgrade:recycle', function(slot)
    local src = source
    local player = ox_inventory:GetPlayer(src)
    local inv = player and player.inventory
    local item = inv[slot]
    if not item or not item.metadata.level or item.metadata.level <= 1 then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Chỉ tái chế vật phẩm cấp cao!', type = 'error'})
        return
    end
    local refundStone = math.floor(item.metadata.level * 0.5)
    local stoneType = Config.UpgradeItems[item.name].upgradeStones[item.metadata.level]
    ox_inventory:AddItem(src, stoneType, refundStone)
    ox_inventory:RemoveItem(src, item.name, 1, nil, slot)
    TriggerClientEvent('ox_lib:notify', src, {description = ('Nhận lại %d %s!'):format(refundStone, stoneType), type = 'success'})
    TriggerClientEvent('upgrade:effect', src, 'recycle')
end)

RegisterNetEvent('upgrade:effectAll', function(effectType, name, item, level)
    TriggerClientEvent('upgrade:effect', -1, effectType, name, item, level)
end)
