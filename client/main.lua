local ox_inventory = exports.ox_inventory

-- Backpack Upgrade System Client
RegisterNetEvent('backpack:openUpgradeMenu', function()
    local playerData = ox_inventory:GetPlayerData()
    local inventory = playerData.inventory
    
    local backpacks = {}
    for slot, item in pairs(inventory) do
        if item and Config.BackpackLookup[item.name] then
            table.insert(backpacks, {
                slot = slot,
                item = item,
                config = Config.BackpackLookup[item.name]
            })
        end
    end
    
    SendNUIMessage({
        action = 'openUpgrade',
        backpacks = backpacks
    })
    SetNuiFocus(true, true)
end)

-- Handle backpack upgrade request
RegisterNUICallback('upgradeBackpack', function(data, cb)
    local slot = data.slot
    local targetBackpack = data.targetBackpack
    
    TriggerServerEvent('backpack:upgrade', slot, targetBackpack)
    cb({success = true})
end)

-- Handle backpack smash request
RegisterNUICallback('smashBackpack', function(data, cb)
    local slot = data.slot
    
    TriggerServerEvent('backpack:smash', slot)
    cb({success = true})
end)

-- Get backpacks callback
RegisterNUICallback('getBackpacks', function(data, cb)
    lib.callback('backpack:getPlayerBackpacks', false, function(backpacks)
        cb({success = true, backpacks = backpacks})
    end)
end)

-- Get upgrade options callback
RegisterNUICallback('getUpgradeOptions', function(data, cb)
    local backpackName = data.backpackName
    lib.callback('backpack:getUpgradeOptions', false, function(options)
        cb({success = true, options = options})
    end, backpackName)
end)

-- Get ranking callback
RegisterNUICallback('getRanking', function(data, cb)
    lib.callback('upgrade:getRank', false, function(ranking)
        cb(ranking)
    end)
end)

-- Close NUI
RegisterNUICallback('closeMenu', function(data, cb)
    SetNuiFocus(false, false)
    cb({success = true})
end)

-- Handle upgrade effects
RegisterNetEvent('upgrade:effect', function(effectType, playerName, itemName, level)
    -- Visual and audio effects for upgrades
    if effectType == 'success' then
        -- Success effect
        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            multiline = true,
            args = {"[THÀNH CÔNG]", (playerName or "Bạn") .. " đã nâng cấp " .. (itemName or "balo") .. " lên cấp " .. (level or "?")}
        })
        
        -- Play success sound if available
        PlaySoundFrontend(-1, "PURCHASE", "HUD_LIQUOR_STORE_SOUNDSET", 1)
        
    elseif effectType == 'fail' then
        -- Failure effect
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"[THẤT BẠI]", (playerName or "Bạn") .. " đã thất bại khi nâng cấp " .. (itemName or "balo")}
        })
        
        -- Play failure sound
        PlaySoundFrontend(-1, "CANCEL", "HUD_FREEMODE_SOUNDSET", 1)
        
    elseif effectType == 'transfer' then
        -- Transfer effect
        TriggerEvent('chat:addMessage', {
            color = {0, 0, 255},
            multiline = true,
            args = {"[DI TRUYỀN]", "Đã chuyển cấp thành công!"}
        })
        
    elseif effectType == 'recycle' then
        -- Recycle effect
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 0},
            multiline = true,
            args = {"[TÁI CHẾ]", "Đã tái chế thành công!"}
        })
    end
end)

-- Command to open backpack upgrade menu
RegisterCommand('backpack', function()
    TriggerEvent('backpack:openUpgradeMenu')
end, false)

-- Export for other resources
exports('openBackpackMenu', function()
    TriggerEvent('backpack:openUpgradeMenu')
end)