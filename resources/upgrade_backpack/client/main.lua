local isNUIOpen = false

-- Key mappings
RegisterKeyMapping('upgrade_backpack', 'Open Backpack Upgrade Menu', 'keyboard', 'F6')

-- Command to open upgrade menu
RegisterCommand('upgrade_backpack', function()
    openUpgradeNUI()
end, false)

-- Function to open NUI
function openUpgradeNUI()
    if isNUIOpen then return end
    
    isNUIOpen = true
    SetNuiFocus(true, true)
    
    -- Get player inventory and send to NUI
    lib.callback('upgrade_backpack:getInventory', false, function(inventory)
        SendNUIMessage({
            action = 'showNUI',
            inventory = inventory,
            config = {
                upgradeItems = Config.UpgradeItems,
                rankTitles = Config.RankTitles,
                defaultTab = Config.NUI.defaultTab
            }
        })
    end)
end

-- Function to close NUI
function closeUpgradeNUI()
    if not isNUIOpen then return end
    
    isNUIOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({action = 'hideNUI'})
end

-- NUI Callbacks

-- Close NUI
RegisterNUICallback('closeNUI', function(data, cb)
    closeUpgradeNUI()
    cb('ok')
end)

-- Get ranking data
RegisterNUICallback('getRanking', function(data, cb)
    lib.callback('upgrade_backpack:getRanking', false, function(rankData)
        cb(rankData)
    end)
end)

-- Upgrade item
RegisterNUICallback('upgradeItem', function(data, cb)
    local slot = data.slot
    local itemName = data.itemName
    
    if not slot or not itemName then
        cb({success = false, message = 'Dữ liệu không hợp lệ!'})
        return
    end
    
    lib.callback('upgrade_backpack:upgradeItem', false, function(result)
        cb(result)
        
        -- Refresh inventory after upgrade
        if result.success then
            refreshInventory()
        end
    end, slot, itemName)
end)

-- Transfer level between items
RegisterNUICallback('transferLevel', function(data, cb)
    local srcSlot = data.srcSlot
    local dstSlot = data.dstSlot
    
    if not srcSlot or not dstSlot then
        cb({success = false, message = 'Chọn 2 vật phẩm để di truyền!'})
        return
    end
    
    TriggerServerEvent('upgrade_backpack:transfer', srcSlot, dstSlot)
    
    -- Refresh inventory after transfer
    Citizen.SetTimeout(1000, function()
        refreshInventory()
    end)
    
    cb({success = true, message = 'Đang xử lý di truyền...'})
end)

-- Recycle item
RegisterNUICallback('recycleItem', function(data, cb)
    local slot = data.slot
    
    if not slot then
        cb({success = false, message = 'Chọn vật phẩm để tái chế!'})
        return
    end
    
    TriggerServerEvent('upgrade_backpack:recycle', slot)
    
    -- Refresh inventory after recycle
    Citizen.SetTimeout(1000, function()
        refreshInventory()
    end)
    
    cb({success = true, message = 'Đang xử lý tái chế...'})
end)

-- Refresh inventory data in NUI
function refreshInventory()
    if not isNUIOpen then return end
    
    lib.callback('upgrade_backpack:getInventory', false, function(inventory)
        SendNUIMessage({
            action = 'updateInventory',
            inventory = inventory
        })
    end)
end

-- Handle effects from server
RegisterNetEvent('upgrade_backpack:effect', function(effectType, level, playerName, itemName)
    if Config.NUI.enableEffects then
        -- Play visual effects
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        
        if effectType == 'success' then
            -- Success effect
            RequestNamedPtfxAsset(Config.Effects.successEffect)
            while not HasNamedPtfxAssetLoaded(Config.Effects.successEffect) do
                Citizen.Wait(1)
            end
            UseParticleFxAssetNextCall(Config.Effects.successEffect)
            StartParticleFxLoopedAtCoord("ent_dst_elec_fire", coords.x, coords.y, coords.z + 1.0, 0.0, 0.0, 0.0, 1.0, false, false, false)
            
        elseif effectType == 'fail' then
            -- Fail effect
            RequestNamedPtfxAsset(Config.Effects.failEffect)
            while not HasNamedPtfxAssetLoaded(Config.Effects.failEffect) do
                Citizen.Wait(1)
            end
            UseParticleFxAssetNextCall(Config.Effects.failEffect)
            StartParticleFxLoopedAtCoord("ent_dst_gen_gobstop", coords.x, coords.y, coords.z + 1.0, 0.0, 0.0, 0.0, 1.0, false, false, false)
            
        elseif effectType == 'transfer' then
            -- Transfer effect
            RequestNamedPtfxAsset(Config.Effects.transferEffect)
            while not HasNamedPtfxAssetLoaded(Config.Effects.transferEffect) do
                Citizen.Wait(1)
            end
            UseParticleFxAssetNextCall(Config.Effects.transferEffect)
            StartParticleFxLoopedAtCoord("ent_sht_flame", coords.x, coords.y, coords.z + 1.0, 0.0, 0.0, 0.0, 1.0, false, false, false)
            
        elseif effectType == 'recycle' then
            -- Recycle effect
            RequestNamedPtfxAsset(Config.Effects.recycleEffect)
            while not HasNamedPtfxAssetLoaded(Config.Effects.recycleEffect) do
                Citizen.Wait(1)
            end
            UseParticleFxAssetNextCall(Config.Effects.recycleEffect)
            StartParticleFxLoopedAtCoord("ent_dst_inflate_ball", coords.x, coords.y, coords.z + 1.0, 0.0, 0.0, 0.0, 1.0, false, false, false)
            
        elseif effectType == 'upgrade_success' then
            -- Global success notification
            if playerName and itemName and level then
                lib.notify({
                    title = 'Nâng cấp thành công!',
                    description = string.format('%s đã nâng cấp %s lên cấp %d!', playerName, itemName, level),
                    type = 'success',
                    duration = 3000
                })
            end
        end
    end
    
    -- Play sound if enabled
    if Config.NUI.enableSound then
        if effectType == 'success' then
            PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", 1)
        elseif effectType == 'fail' then
            PlaySoundFrontend(-1, "CHECKPOINT_MISSED", "HUD_MINI_GAME_SOUNDSET", 1)
        else
            PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
        end
    end
end)

-- Show NUI from server
RegisterNetEvent('upgrade_backpack:showNUI', function()
    openUpgradeNUI()
end)

-- Handle ESC key to close NUI
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isNUIOpen then
            if IsControlJustPressed(0, 322) then -- ESC key
                closeUpgradeNUI()
            end
        else
            Citizen.Wait(500)
        end
    end
end)

-- Export functions for other resources
exports('openUpgradeNUI', openUpgradeNUI)
exports('closeUpgradeNUI', closeUpgradeNUI)
exports('isNUIOpen', function() return isNUIOpen end)

print('^2[upgrade_backpack]^7 Client loaded successfully!')