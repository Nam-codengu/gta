local isMenuOpen = false

RegisterCommand('upgrade', function()
    openUpgradeMenu()
end)

RegisterKeyMapping('upgrade', 'Mở menu nâng cấp', 'keyboard', 'F7')

function openUpgradeMenu()
    if isMenuOpen then return end
    
    isMenuOpen = true
    SetNuiFocus(true, true)
    
    -- Send upgrade items from config to NUI
    SendNUIMessage({
        type = 'openMenu',
        upgradeItems = Config.UpgradeItems
    })
end

RegisterNUICallback('closeMenu', function(data, cb)
    closeUpgradeMenu()
    cb('ok')
end)

RegisterNUICallback('getRanking', function(data, cb)
    -- Use the same callback as server
    local result = lib.callback.await('upgrade:getRank', false)
    cb(result)
end)

function closeUpgradeMenu()
    if not isMenuOpen then return end
    
    isMenuOpen = false
    SetNuiFocus(false, false)
    
    SendNUIMessage({
        type = 'closeMenu'
    })
end

-- Close menu on ESC
RegisterNUICallback('escape', function(data, cb)
    closeUpgradeMenu()
    cb('ok')
end)