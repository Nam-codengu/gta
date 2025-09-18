local ox_inventory = exports.ox_inventory
local isNuiOpen = false

-- Open backpack upgrade menu
RegisterCommand('backpack_upgrade', function()
    if not isNuiOpen then
        OpenBackpackMenu()
    end
end)

-- Key mapping for opening menu
RegisterKeyMapping('backpack_upgrade', 'Mở menu nâng cấp balo', 'keyboard', 'F6')

-- Function to open the backpack upgrade menu
function OpenBackpackMenu()
    isNuiOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openMenu',
        playerInventory = GetPlayerInventoryData()
    })
end

-- Function to close the menu
function CloseBackpackMenu()
    isNuiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'closeMenu'
    })
end

-- Get player inventory data for NUI
function GetPlayerInventoryData()
    local playerData = {}
    local inventory = ox_inventory:GetPlayerItems()
    
    if inventory then
        for slot, item in pairs(inventory) do
            if item and ConfigBackpacks.GetBackpackInfo(item.name) then
                table.insert(playerData, {
                    slot = slot,
                    name = item.name,
                    label = item.label,
                    count = item.count,
                    metadata = item.metadata or {},
                    backpackInfo = ConfigBackpacks.GetBackpackInfo(item.name)
                })
            end
        end
    end
    
    return playerData
end

-- NUI Callbacks
RegisterNUICallback('closeMenu', function(data, cb)
    CloseBackpackMenu()
    cb('ok')
end)

RegisterNUICallback('upgradeBackpack', function(data, cb)
    local slot = data.slot
    local inventory = ox_inventory:GetPlayerItems()
    local item = inventory[slot]
    
    if not item then
        TriggerEvent('ox_lib:notify', {description = 'Không tìm thấy balo!', type = 'error'})
        cb('error')
        return
    end
    
    local backpackInfo = ConfigBackpacks.GetBackpackInfo(item.name)
    if not backpackInfo then
        TriggerEvent('ox_lib:notify', {description = 'Vật phẩm không phải balo!', type = 'error'})
        cb('error')
        return
    end
    
    if backpackInfo.level >= 5 then
        TriggerEvent('ox_lib:notify', {description = 'Balo đã đạt cấp tối đa!', type = 'error'})
        cb('error')
        return
    end
    
    -- Check for required stone
    local requiredStone = ConfigBackpacks.GetRequiredStone(backpackInfo.level)
    local hasStone = false
    
    for _, invItem in pairs(inventory) do
        if invItem and invItem.name == requiredStone and invItem.count > 0 then
            hasStone = true
            break
        end
    end
    
    if not hasStone then
        TriggerEvent('ox_lib:notify', {description = 'Không có đá nâng cấp cần thiết!', type = 'error'})
        cb('error')
        return
    end
    
    -- Send to server for processing
    TriggerServerEvent('backpack:upgrade', slot)
    cb('ok')
end)

RegisterNUICallback('transferLevel', function(data, cb)
    local sourceSlot = data.sourceSlot
    local targetSlot = data.targetSlot
    
    if sourceSlot == targetSlot then
        TriggerEvent('ox_lib:notify', {description = 'Không thể di truyền cho chính nó!', type = 'error'})
        cb('error')
        return
    end
    
    TriggerServerEvent('backpack:transfer', sourceSlot, targetSlot)
    cb('ok')
end)

RegisterNUICallback('recycleBackpack', function(data, cb)
    local slot = data.slot
    TriggerServerEvent('backpack:recycle', slot)
    cb('ok')
end)

RegisterNUICallback('getRankings', function(data, cb)
    TriggerServerEvent('backpack:getRankings')
    cb('ok')
end)

RegisterNUICallback('refreshInventory', function(data, cb)
    cb({
        inventory = GetPlayerInventoryData()
    })
end)

-- Server events
RegisterNetEvent('backpack:upgradeResult', function(success, newItem, level)
    SendNUIMessage({
        action = 'upgradeResult',
        success = success,
        newItem = newItem,
        level = level,
        inventory = GetPlayerInventoryData()
    })
    
    if success then
        TriggerEvent('ox_lib:notify', {description = string.format('Nâng cấp thành công lên cấp %d!', level), type = 'success'})
        TriggerEvent('backpack:playEffect', 'upgrade_success')
    else
        TriggerEvent('ox_lib:notify', {description = 'Nâng cấp thất bại!', type = 'error'})
        TriggerEvent('backpack:playEffect', 'upgrade_fail')
    end
end)

RegisterNetEvent('backpack:transferResult', function(success)
    SendNUIMessage({
        action = 'transferResult',
        success = success,
        inventory = GetPlayerInventoryData()
    })
    
    if success then
        TriggerEvent('ox_lib:notify', {description = 'Di truyền cấp thành công!', type = 'success'})
        TriggerEvent('backpack:playEffect', 'transfer')
    else
        TriggerEvent('ox_lib:notify', {description = 'Di truyền cấp thất bại!', type = 'error'})
    end
end)

RegisterNetEvent('backpack:recycleResult', function(success, stones)
    SendNUIMessage({
        action = 'recycleResult',
        success = success,
        stones = stones,
        inventory = GetPlayerInventoryData()
    })
    
    if success then
        TriggerEvent('ox_lib:notify', {description = string.format('Tái chế thành công, nhận được %d đá!', stones), type = 'success'})
        TriggerEvent('backpack:playEffect', 'recycle')
    end
end)

RegisterNetEvent('backpack:rankingsResult', function(rankings)
    SendNUIMessage({
        action = 'rankingsResult',
        rankings = rankings
    })
end)

-- Visual effects
RegisterNetEvent('backpack:playEffect', function(effectType)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    if effectType == 'upgrade_success' then
        -- Green particle effect for success
        SetPtfxAssetNextCall('scr_rcbarry2')
        StartParticleFxLoopedAtCoord('scr_clown_appears', coords.x, coords.y, coords.z + 1.0, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
    elseif effectType == 'upgrade_fail' then
        -- Red particle effect for failure
        SetPtfxAssetNextCall('scr_trevor1')
        StartParticleFxLoopedAtCoord('scr_trev1_trailer_boosh', coords.x, coords.y, coords.z + 1.0, 0.0, 0.0, 0.0, 0.5, false, false, false, false)
    elseif effectType == 'transfer' then
        -- Blue particle effect for transfer
        SetPtfxAssetNextCall('scr_rcbarry1')
        StartParticleFxLoopedAtCoord('scr_alien_disintegrate', coords.x, coords.y, coords.z + 1.0, 0.0, 0.0, 0.0, 0.8, false, false, false, false)
    elseif effectType == 'recycle' then
        -- Yellow particle effect for recycle
        SetPtfxAssetNextCall('scr_rcbarry2')
        StartParticleFxLoopedAtCoord('scr_clown_appears', coords.x, coords.y, coords.z + 1.0, 0.0, 0.0, 0.0, 0.6, false, false, false, false)
    end
end)

-- ESC key handler
CreateThread(function()
    while true do
        Wait(0)
        if isNuiOpen then
            if IsControlJustPressed(0, 322) then -- ESC key
                CloseBackpackMenu()
            end
        else
            Wait(500)
        end
    end
end)