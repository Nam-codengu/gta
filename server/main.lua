local ox_inventory = exports.ox_inventory

MySQL.ready(function()
    MySQL.query([[ 
        CREATE TABLE IF NOT EXISTS upgrade_log (
            id INT AUTO_INCREMENT PRIMARY KEY,
            identifier VARCHAR(64),
            name VARCHAR(64),
            item VARCHAR(32),
            level INT,
            status VARCHAR(16),
            timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]])
end)

-- Helper function to get player identifier
local function getPlayerIdentifier(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, id in pairs(identifiers) do
        if string.find(id, "license:") then
            return id
        end
    end
    return nil
end

-- Helper function to get player name
local function getPlayerName(source)
    return GetPlayerName(source) or "Unknown"
end

-- Helper function to get next level backpack options
local function getNextLevelBackpacks(currentLevel, gender)
    local nextLevel = currentLevel + 1
    if nextLevel > 12 then return nil end
    
    local options = {}
    if Config.Backpacks[nextLevel] then
        for _, backpack in pairs(Config.Backpacks[nextLevel]) do
            if gender == "unisex" or backpack.gender == gender or backpack.gender == "unisex" then
                table.insert(options, backpack)
            end
        end
    end
    
    return options
end

-- Backpack upgrade system
RegisterNetEvent('backpack:upgrade', function(slot, targetBackpackName)
    local src = source
    local player = ox_inventory:GetPlayer(src)
    local inv = player?.inventory
    if not inv then return end
    
    local item = inv[slot]
    if not item then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Không tìm thấy balo!', type = 'error'})
        return
    end
    
    local currentBackpack = Config.BackpackLookup[item.name]
    if not currentBackpack then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Vật phẩm này không phải balo!', type = 'error'})
        return
    end
    
    local targetBackpack = Config.BackpackLookup[targetBackpackName]
    if not targetBackpack then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Balo đích không hợp lệ!', type = 'error'})
        return
    end
    
    -- Check if target is next level
    if targetBackpack.level ~= currentBackpack.level + 1 then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Chỉ có thể nâng cấp lên cấp kế tiếp!', type = 'error'})
        return
    end
    
    -- Check if player has required upgrade stone
    local requiredStone = targetBackpack.upgradeStone
    local stoneCount = ox_inventory:GetItem(src, requiredStone, nil, true)
    if not stoneCount or stoneCount < Config.UpgradeRequirements.stoneAmount then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Không đủ đá nâng cấp ' .. requiredStone .. '!', type = 'error'})
        return
    end
    
    -- Check talisman requirement
    local requiresTalisman = false
    for _, level in pairs(Config.UpgradeRequirements.requireTalisman) do
        if targetBackpack.level == level then
            requiresTalisman = true
            break
        end
    end
    
    if requiresTalisman then
        local talismanCount = ox_inventory:GetItem(src, Config.UpgradeRequirements.talismanItem, nil, true)
        if not talismanCount or talismanCount < 1 then
            TriggerClientEvent('ox_lib:notify', src, {description = 'Cần bùa may mắn để nâng cấp cấp này!', type = 'error'})
            return
        end
    end
    
    -- Remove upgrade stone
    ox_inventory:RemoveItem(src, requiredStone, Config.UpgradeRequirements.stoneAmount)
    
    -- Remove talisman if required
    if requiresTalisman then
        ox_inventory:RemoveItem(src, Config.UpgradeRequirements.talismanItem, 1)
    end
    
    -- Calculate success chance
    local successChance = targetBackpack.successRate
    local random = math.random(100)
    
    local playerName = getPlayerName(src)
    local playerIdentifier = getPlayerIdentifier(src)
    
    if random <= successChance then
        -- Success: Remove old backpack and add new one
        ox_inventory:RemoveItem(src, item.name, 1, nil, slot)
        
        local newItem = ox_inventory:AddItem(src, targetBackpack.name, 1)
        if newItem then
            -- Set metadata for new backpack
            local metadata = {
                level = targetBackpack.level,
                label = targetBackpack.label,
                upgraded = true
            }
            ox_inventory:SetMetadata(src, newItem.slot, metadata)
            
            TriggerClientEvent('ox_lib:notify', src, {
                description = 'Nâng cấp thành công! Nhận được ' .. targetBackpack.label,
                type = 'success'
            })
            
            -- Log success
            TriggerEvent('upgrade:log', {
                identifier = playerIdentifier,
                name = playerName,
                item = targetBackpack.name,
                level = targetBackpack.level,
                status = 'success'
            })
            
            -- Trigger effects
            TriggerClientEvent('upgrade:effect', src, 'success', playerName, targetBackpack.label, targetBackpack.level)
            TriggerClientEvent('upgrade:effect', -1, 'success', playerName, targetBackpack.label, targetBackpack.level)
        else
            TriggerClientEvent('ox_lib:notify', src, {description = 'Lỗi khi thêm balo mới!', type = 'error'})
        end
    else
        -- Failure: Remove old backpack only
        ox_inventory:RemoveItem(src, item.name, 1, nil, slot)
        
        TriggerClientEvent('ox_lib:notify', src, {
            description = 'Nâng cấp thất bại! Balo đã bị phá hủy.',
            type = 'error'
        })
        
        -- Log failure
        TriggerEvent('upgrade:log', {
            identifier = playerIdentifier,
            name = playerName,
            item = item.name,
            level = currentBackpack.level,
            status = 'fail'
        })
        
        -- Trigger effects
        TriggerClientEvent('upgrade:effect', src, 'fail', playerName, currentBackpack.label, currentBackpack.level)
        TriggerClientEvent('upgrade:effect', -1, 'fail', playerName, currentBackpack.label, currentBackpack.level)
    end
end)

-- Backpack smash system (alternative upgrade method)
RegisterNetEvent('backpack:smash', function(slot)
    local src = source
    local player = ox_inventory:GetPlayer(src)
    local inv = player?.inventory
    if not inv then return end
    
    local item = inv[slot]
    if not item then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Không tìm thấy balo!', type = 'error'})
        return
    end
    
    local currentBackpack = Config.BackpackLookup[item.name]
    if not currentBackpack then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Vật phẩm này không phải balo!', type = 'error'})
        return
    end
    
    if currentBackpack.level >= 12 then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Balo đã ở cấp tối đa!', type = 'error'})
        return
    end
    
    -- Get possible next level backpacks
    local nextOptions = getNextLevelBackpacks(currentBackpack.level, currentBackpack.gender)
    if not nextOptions or #nextOptions == 0 then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Không có balo cấp cao hơn!', type = 'error'})
        return
    end
    
    -- Randomly select a target backpack from same gender
    local targetBackpack = nextOptions[math.random(#nextOptions)]
    
    -- Check if player has required upgrade stone
    local requiredStone = targetBackpack.upgradeStone
    local stoneCount = ox_inventory:GetItem(src, requiredStone, nil, true)
    if not stoneCount or stoneCount < Config.UpgradeRequirements.stoneAmount then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Không đủ đá nâng cấp ' .. requiredStone .. '!', type = 'error'})
        return
    end
    
    -- Remove upgrade stone
    ox_inventory:RemoveItem(src, requiredStone, Config.UpgradeRequirements.stoneAmount)
    
    -- Calculate success chance
    local successChance = targetBackpack.successRate
    local random = math.random(100)
    
    local playerName = getPlayerName(src)
    local playerIdentifier = getPlayerIdentifier(src)
    
    -- Always remove the old backpack first (smash mechanic)
    ox_inventory:RemoveItem(src, item.name, 1, nil, slot)
    
    if random <= successChance then
        -- Success: Add new backpack
        local newItem = ox_inventory:AddItem(src, targetBackpack.name, 1)
        if newItem then
            local metadata = {
                level = targetBackpack.level,
                label = targetBackpack.label,
                upgraded = true
            }
            ox_inventory:SetMetadata(src, newItem.slot, metadata)
            
            TriggerClientEvent('ox_lib:notify', src, {
                description = 'Đập balo thành công! Nhận được ' .. targetBackpack.label,
                type = 'success'
            })
            
            -- Log success
            TriggerEvent('upgrade:log', {
                identifier = playerIdentifier,
                name = playerName,
                item = targetBackpack.name,
                level = targetBackpack.level,
                status = 'success'
            })
            
            TriggerClientEvent('upgrade:effect', src, 'success', playerName, targetBackpack.label, targetBackpack.level)
        end
    else
        -- Failure: No new backpack (already removed old one)
        TriggerClientEvent('ox_lib:notify', src, {
            description = 'Đập balo thất bại! Balo đã bị phá hủy hoàn toàn.',
            type = 'error'
        })
        
        -- Log failure
        TriggerEvent('upgrade:log', {
            identifier = playerIdentifier,
            name = playerName,
            item = item.name,
            level = currentBackpack.level,
            status = 'fail'
        })
        
        TriggerClientEvent('upgrade:effect', src, 'fail', playerName, currentBackpack.label, currentBackpack.level)
    end
end)

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
    local inv = player?.inventory
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
    local inv = player?.inventory
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

RegisterNetEvent('upgrade:transfer', function(srcSlot, dstSlot)
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
    local inv = player?.inventory
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

-- New NUI callbacks for backpack system
lib.callback.register('backpack:getPlayerBackpacks', function(source)
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
end)

lib.callback.register('backpack:getUpgradeOptions', function(source, backpackName)
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
end)
