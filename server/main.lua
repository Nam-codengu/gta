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
