local ox_inventory = exports.ox_inventory

-- Initialize database on startup
MySQL.ready(function()
    if Config.Database.enableLogging then
        MySQL.query(string.format([[ 
            CREATE TABLE IF NOT EXISTS %s (
                id INT AUTO_INCREMENT PRIMARY KEY,
                identifier VARCHAR(64),
                name VARCHAR(64),
                item VARCHAR(32),
                level INT,
                status VARCHAR(16),
                action_type VARCHAR(16),
                timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ]], Config.Database.table))
    end
end)

-- Utility function to get player identifier
local function getPlayerIdentifier(src)
    return GetPlayerIdentifiers(src)[1] or 'unknown'
end

-- Log upgrade actions
local function logUpgradeAction(src, item, level, status, actionType)
    if not Config.Database.enableLogging then return end
    
    local playerName = GetPlayerName(src) or 'Unknown'
    local identifier = getPlayerIdentifier(src)
    
    MySQL.insert(string.format('INSERT INTO %s (identifier, name, item, level, status, action_type) VALUES (?, ?, ?, ?, ?, ?)', 
        Config.Database.table), {
        identifier, playerName, item, level, status, actionType or 'upgrade'
    })
end

-- Get ranking data
lib.callback.register('upgrade_backpack:getRanking', function(source)
    if not Config.Database.enableLogging then 
        return {top = {}, unlucky = nil, lucky = nil, transfer_master = nil, recycle_king = nil}
    end
    
    local top = MySQL.query.await(string.format(
        'SELECT name, MAX(level) as level FROM %s WHERE status="success" AND action_type="upgrade" GROUP BY identifier ORDER BY level DESC LIMIT 10',
        Config.Database.table
    ))
    
    local unlucky = MySQL.query.await(string.format(
        'SELECT name, COUNT(*) as fail_count FROM %s WHERE status="fail" AND action_type="upgrade" GROUP BY identifier ORDER BY fail_count DESC LIMIT 1',
        Config.Database.table
    ))
    
    local lucky = MySQL.query.await(string.format(
        'SELECT name, COUNT(*) as success_count FROM %s WHERE status="success" AND action_type="upgrade" GROUP BY identifier ORDER BY success_count DESC LIMIT 1',
        Config.Database.table
    ))
    
    local transferMaster = MySQL.query.await(string.format(
        'SELECT name, COUNT(*) as transfer_count FROM %s WHERE status="success" AND action_type="transfer" GROUP BY identifier ORDER BY transfer_count DESC LIMIT 1',
        Config.Database.table
    ))
    
    local recycleKing = MySQL.query.await(string.format(
        'SELECT name, COUNT(*) as recycle_count FROM %s WHERE status="success" AND action_type="recycle" GROUP BY identifier ORDER BY recycle_count DESC LIMIT 1',
        Config.Database.table
    ))
    
    return {
        top = top or {},
        unlucky = unlucky[1] or nil,
        lucky = lucky[1] or nil,
        transfer_master = transferMaster[1] or nil,
        recycle_king = recycleKing[1] or nil
    }
end)

-- Upgrade item callback
lib.callback.register('upgrade_backpack:upgradeItem', function(source, slot, itemName)
    local src = source
    local player = ox_inventory:GetPlayer(src)
    if not player or not player.inventory then 
        return {success = false, message = 'Không thể truy cập inventory!'}
    end
    
    local item = player.inventory[slot]
    if not item or item.name ~= itemName then
        return {success = false, message = 'Vật phẩm không hợp lệ!'}
    end
    
    local config = Config.UpgradeItems[itemName]
    if not config then
        return {success = false, message = 'Vật phẩm này không thể nâng cấp!'}
    end
    
    local currentLevel = item.metadata.level or 0
    if currentLevel >= config.maxLevel then
        return {success = false, message = 'Đã đạt cấp tối đa!'}
    end
    
    local nextLevel = currentLevel + 1
    local requiredStone = config.upgradeStones[nextLevel]
    local successRate = config.rates[nextLevel]
    
    -- Check if player has required upgrade stone
    local stoneCount = ox_inventory:Search(src, 'count', requiredStone)
    if stoneCount < 1 then
        return {success = false, message = string.format('Cần có %s để nâng cấp!', requiredStone)}
    end
    
    -- Check if talisman is required for this level
    local needTalisman = false
    for _, reqLevel in ipairs(config.requireTalismanAt) do
        if nextLevel == reqLevel then
            needTalisman = true
            break
        end
    end
    
    if needTalisman then
        local talismanCount = ox_inventory:Search(src, 'count', 'talisman')
        if talismanCount < 1 then
            return {success = false, message = 'Cần có bùa may mắn cho cấp này!'}
        end
    end
    
    -- Remove upgrade stone
    ox_inventory:RemoveItem(src, requiredStone, 1)
    if needTalisman then
        ox_inventory:RemoveItem(src, 'talisman', 1)
    end
    
    -- Roll for success
    local isSuccess = math.random(100) <= successRate
    
    if isSuccess then
        -- Success - upgrade item
        item.metadata.level = nextLevel
        if config.slotPerLevel > 0 then
            item.metadata.slots = (item.metadata.slots or 0) + config.slotPerLevel
        end
        if config.weightPerLevel > 0 then
            item.metadata.weight = (item.metadata.weight or 0) + config.weightPerLevel
        end
        
        ox_inventory:SetMetadata(src, slot, item.metadata)
        logUpgradeAction(src, itemName, nextLevel, 'success', 'upgrade')
        
        -- Trigger effects
        TriggerClientEvent('upgrade_backpack:effect', src, 'success', nextLevel)
        TriggerClientEvent('upgrade_backpack:effect', -1, 'upgrade_success', GetPlayerName(src), itemName, nextLevel)
        
        return {success = true, message = string.format('Nâng cấp thành công lên cấp %d!', nextLevel), level = nextLevel}
    else
        -- Failure
        logUpgradeAction(src, itemName, nextLevel, 'fail', 'upgrade')
        
        -- Trigger effects
        TriggerClientEvent('upgrade_backpack:effect', src, 'fail', currentLevel)
        
        return {success = false, message = 'Nâng cấp thất bại!', level = currentLevel}
    end
end)

-- Transfer level between items
RegisterNetEvent('upgrade_backpack:transfer', function(srcSlot, dstSlot)
    local src = source
    local player = ox_inventory:GetPlayer(src)
    local inv = player?.inventory
    if not inv then return end
    
    local itemSrc = inv[srcSlot]
    local itemDst = inv[dstSlot]
    
    if not itemSrc or not itemDst or itemSrc.name ~= itemDst.name then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Hai vật phẩm không hợp lệ!', type = 'error'})
        return
    end
    
    local srcLevel = itemSrc.metadata.level or 0
    local dstLevel = itemDst.metadata.level or 0
    
    if srcLevel <= dstLevel then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Cấp nguồn phải cao hơn cấp đích!', type = 'error'})
        return
    end
    
    -- Transfer with chance of level reduction
    local transferLevel = srcLevel
    if math.random(100) <= 15 then -- 15% chance to lose 1 level
        transferLevel = srcLevel - 1
    end
    
    -- Update destination item
    itemDst.metadata.level = transferLevel
    local config = Config.UpgradeItems[itemDst.name]
    if config then
        if config.slotPerLevel > 0 then
            itemDst.metadata.slots = transferLevel * config.slotPerLevel
        end
        if config.weightPerLevel > 0 then
            itemDst.metadata.weight = transferLevel * config.weightPerLevel
        end
    end
    
    ox_inventory:SetMetadata(src, dstSlot, itemDst.metadata)
    ox_inventory:RemoveItem(src, itemSrc.name, 1, nil, srcSlot)
    
    logUpgradeAction(src, itemDst.name, transferLevel, 'success', 'transfer')
    
    TriggerClientEvent('ox_lib:notify', src, {description = 'Di truyền cấp thành công!', type = 'success'})
    TriggerClientEvent('upgrade_backpack:effect', src, 'transfer', transferLevel)
end)

-- Recycle item for materials
RegisterNetEvent('upgrade_backpack:recycle', function(slot)
    local src = source
    local player = ox_inventory:GetPlayer(src)
    local inv = player?.inventory
    local item = inv[slot]
    
    if not item or not item.metadata.level or item.metadata.level <= 1 then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Chỉ tái chế được vật phẩm cấp 2 trở lên!', type = 'error'})
        return
    end
    
    local config = Config.UpgradeItems[item.name]
    if not config then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Vật phẩm này không thể tái chế!', type = 'error'})
        return
    end
    
    local level = item.metadata.level
    local refundStone = math.floor(level * 0.6) -- Return 60% of stones used
    local stoneType = config.upgradeStones[level]
    
    ox_inventory:AddItem(src, stoneType, refundStone)
    ox_inventory:RemoveItem(src, item.name, 1, nil, slot)
    
    logUpgradeAction(src, item.name, level, 'success', 'recycle')
    
    TriggerClientEvent('ox_lib:notify', src, {
        description = string.format('Tái chế thành công! Nhận lại %d %s', refundStone, stoneType), 
        type = 'success'
    })
    TriggerClientEvent('upgrade_backpack:effect', src, 'recycle', level)
end)

-- Get player inventory for NUI
lib.callback.register('upgrade_backpack:getInventory', function(source)
    local src = source
    local player = ox_inventory:GetPlayer(src)
    if not player or not player.inventory then return {} end
    
    local items = {}
    for slot, item in pairs(player.inventory) do
        if item and Config.UpgradeItems[item.name] then
            table.insert(items, {
                slot = slot,
                name = item.name,
                label = item.label,
                count = item.count,
                level = item.metadata.level or 0,
                maxLevel = Config.UpgradeItems[item.name].maxLevel
            })
        end
    end
    
    return items
end)

-- Open upgrade NUI
RegisterNetEvent('upgrade_backpack:openNUI', function()
    local src = source
    TriggerClientEvent('upgrade_backpack:showNUI', src)
end)

print('^2[upgrade_backpack]^7 Server loaded successfully!')