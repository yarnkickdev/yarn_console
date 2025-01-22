local resourceName = GetCurrentResourceName()

local function generateItemIdentifier()
    local prefix = "CRACK_"
    local randomNumbers = tostring(math.random(10, 99))
    local randomLetters = string.char(math.random(65, 90)) .. string.char(math.random(65, 90))
    local finalNumbers = tostring(math.random(10, 99))

    return prefix .. randomNumbers .. randomLetters .. finalNumbers
end

exports.ox_inventory:registerHook('createItem', function(payload)
    return {
        deviceId = 'hacking_device',
        deviceLabel = 'Hacking Device',
        deviceUsb = generateItemIdentifier(),
        durability = 100,
        noDuplicate = false,
    }
end, {
    itemFilter = {
        ['hacking_device'] = true
    }
})

lib.callback.register(('%s:FailHack'):format(resourceName), function(source, item, dId)
    -- print(json.encode(item, {indent = true}))
    local inv = ('fd_laptop_%s'):format(dId)
    local newItem = exports.ox_inventory:Search(inv, item.slot, item.metadata.deviceId, nil)
    print(json.encode(newItem, {indent = true}))
    local durability = newItem.metadata and newItem.metadata.durability or item.metadata.durability or 100
    durability = durability - math.random(10, 33)
    if durability <= 0 then
        durability = 0
        TriggerClientEvent("fd_laptop:sendNotification", source, {
            summary = 'Overheat Alert',
            detail = ('%s device has overheated! Please take action immediately.'):format(item.metadata.deviceUsb)
        })
    else
        TriggerClientEvent("fd_laptop:sendNotification", source, {
            summary = 'Temperature Rising',
            detail = ('%s device temperature is rising! Please monitor closely.'):format(item.metadata.deviceUsb)
        })
    end
    exports.ox_inventory:SetDurability(inv, item.slot, durability)
    return
end)