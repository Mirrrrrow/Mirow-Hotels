local ESX = exports["es_extended"]:getSharedObject()

local query = "SELECT * FROM users WHERE identifier = ?"
local query2 = "SELECT * FROM hotels WHERE owner = ?"
local query3 = "SELECT * FROM hotels WHERE id = ?"

ESX.RegisterServerCallback('hotel:getCurrentHotel', function(source,cb)
    local __source = source
    local xPlayer = ESX.GetPlayerFromId(__source)
    MySQL.query(query, {xPlayer.identifier}, function(result)
        if #result == 0 then
            print('[Mirow-Hotels] No user found')
            cb(nil)
        end
        local player = result[1]
        MySQL.query(query2, {xPlayer.identifier}, function(result2)
            if #result2 == 0 then
                print('[Mirow-Hotels] No user found')
                cb(player.hotelroom)
            else
                cb(player.hotelroom, result2[1].price)
            end

        end)

    end)
end)

ESX.RegisterServerCallback('hotel:getFreeRooms', function(source,cb)
    local __source = source
    local xPlayer = ESX.GetPlayerFromId(__source)
    MySQL.query(query2, {"none"}, function(result)
        local rooms = {}
        for k,v in ipairs(result) do
            table.insert(rooms, {
                room = v.id,
                price = v.price
            })
        end
        cb(rooms)
    end)
end)

ESX.RegisterServerCallback('hotel:rentRoom', function(source,cb,room,price)
    local __source = source
    local xPlayer = ESX.GetPlayerFromId(__source)
    MySQL.query(query3, {tonumber(room)}, function(result)
        local room = result[1]
        if room.owner == "none" then
            if xPlayer.getAccount("bank").money >= tonumber(price) then
                xPlayer.removeAccountMoney('bank', tonumber(price))
                MySQL.query("UPDATE hotels SET owner = ? WHERE owner = ?", {"none", xPlayer.identifier})
                MySQL.query("UPDATE users SET hotelroom = ? WHERE identifier = ?", {room.id, xPlayer.identifier})
                MySQL.query("UPDATE hotels SET owner = ? WHERE id = ?", {xPlayer.identifier, room.id})
                MySQL.query("UPDATE hotels SET minibar = ? WHERE id = ?", {json.encode(Config.HotelData.MiniBar), room.id})
                cb("success")
            else
                cb("money")
            end
        else
            cb("owned")
        end
    end)
end)

ESX.RegisterServerCallback('hotel:getRoomPosition', function(source,cb,room)
    local __source = source
    local xPlayer = ESX.GetPlayerFromId(__source)
    MySQL.query(query3, {tonumber(room)}, function(result)
        local room = result[1]
        if room.owner == xPlayer.identifier then
            local pos = json.decode(room.position)
            cb(pos.x, pos.y, pos.z)
        else
            cb(false, false, false)
        end
    end)
end)

RegisterServerEvent('hotel:checkout')
AddEventHandler('hotel:checkout', function(room)
    local __source = source
    local xPlayer = ESX.GetPlayerFromId(__source)
    TriggerClientEvent('ESX:TextUI', __source, "You checked out of your hotel room (Number " ..tostring(room).. ")", "success")
    MySQL.query("UPDATE users SET hotelroom = ? WHERE identifier = ?", {0, xPlayer.identifier})
    MySQL.query("UPDATE hotels SET owner = ? WHERE id = ?", {"none", room})
end)

RegisterServerEvent('hotel:load')
AddEventHandler('hotel:load', function()
    local __source = source
    local xPlayer = ESX.GetPlayerFromId(__source)
    MySQL.query(query, {xPlayer.identifier}, function(result)
        if #result == 0 then
            print('[Mirow-Hotels] No user found')
            cb(nil)
        end
        local player = result[1]
        MySQL.query(query3, {player.hotelroom}, function(result2)
            if #result2 == 0 then
                print('[Mirow-Hotels] No user found')
            else
                local toCB = result2[1]
                toCB.position = json.decode(result2[1].position)
                TriggerClientEvent('hotel:load', __source, toCB)
            end

        end)
    end)
end)

RegisterServerEvent('hotel:loadCurrentRoom')
AddEventHandler('hotel:loadCurrentRoom', function()
    local __source = source
    local xPlayer = ESX.GetPlayerFromId(__source)
    MySQL.query(query, {xPlayer.identifier}, function(result)
        if #result == 0 then
            print('[Mirow-Hotels] No user found')
        end
        local player = result[1]
        TriggerClientEvent('hotel:loadCurrentRoom', __source, player.inhotelroom)
    end)
end)

RegisterServerEvent('hotel:enterRoom')
AddEventHandler('hotel:enterRoom', function(id)
    local __source = source
    local xPlayer = ESX.GetPlayerFromId(__source)
    MySQL.query("UPDATE users SET inhotelroom = ? WHERE identifier = ?", {id, xPlayer.identifier})
    SetPlayerRoutingBucket(__source, id)
end)

RegisterServerEvent('hotel:exitRoom')
AddEventHandler('hotel:exitRoom', function()
    local __source = source
    local xPlayer = ESX.GetPlayerFromId(__source)
    MySQL.query("UPDATE users SET inhotelroom = ? WHERE identifier = ?", {0, xPlayer.identifier})
    SetPlayerRoutingBucket(__source, 0)
end)

ESX.RegisterServerCallback('hotel:getMinibar', function(source,cb,roomid)
    local __source = source
    local xPlayer = ESX.GetPlayerFromId(__source)
    MySQL.query(query3, {tonumber(roomid)}, function(result)
        local room = result[1]
        if room.owner == xPlayer.identifier then
            local minibar = json.decode(room.minibar)
            cb(minibar)
        else
            cb(false)
        end
    end)
end)

RegisterServerEvent('hotel:payCheck')
AddEventHandler('hotel:payCheck', function(playerSource)
    local __source = playerSource
    local xPlayer = ESX.GetPlayerFromId(__source)
    MySQL.query(query2, {xPlayer.identifier}, function(result)
        if #result == 0 then
            return
        end
        local room = result[1]
        if room.owner == xPlayer.identifier then
            local price = room.price
            xPlayer.removeAccountMoney('bank', tonumber(price))
            TriggerClientEvent('ESX:TextUI', __source, "You paid $" ..tostring(price).. " for your hotel room", "success")
            Wait(3500)
            TriggerClientEvent('ESX:HideUI', __source)
        end
    end)
end)

ESX.RegisterCommand('createroom', 'admin', function(xPlayer, args, showError)
    if not args.price then args.price = 0 end
    if not args.number then return end
    MySQL.query("INSERT INTO hotels (id, price, owner, position, minibar) VALUES (?, ?, ?, ?, ?)", {args.number, args.price, "none", json.encode(xPlayer.getCoords(false)), json.encode(Config.HotelData.MiniBar)})
    TriggerClientEvent('ESX:TextUI', xPlayer.source, "You created a hotel room (Number " ..tostring(args.number).. ")", "success")
    Wait(3500)
    TriggerClientEvent('ESX:HideUI', xPlayer.source)
end, true, {help = "Creates a Hotel Room", arguments = {
    {name = "number", help = "The ID of the Room (Unique)", type = "number"},
    {name = "price", help = "The Price of the Room", type = "number"},
}})