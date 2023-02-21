ESX = exports["es_extended"]:getSharedObject()
local menu = {}
local _menuPool = NativeUI.CreatePool()
local showDistance = false
local loaded = false
local currentRoom = 0
local hotel = {}
CreateThread(function()
    while ESX == nil do Wait(1) end
    TriggerServerEvent("hotel:load")
    TriggerServerEvent("hotel:loadCurrentRoom")
end)
CreateThread(function()
    while true do
        _menuPool:ProcessMenus()

        Wait(1)
    end
end)

RegisterNetEvent('hotel:load')
AddEventHandler('hotel:load', function(playerHotel)
    hotel = playerHotel
    loaded = true
end)

RegisterNetEvent('hotel:loadCurrentRoom')
AddEventHandler('hotel:loadCurrentRoom', function(roomId)
    currentRoom = roomId
end)

local enterSend = false
local exitSend = false
CreateThread(function()
    while true do
        Wait(1)
        if hotel ~= {} and loaded then
            local player = PlayerPedId()
            local playerCoords = GetEntityCoords(player)
            local hotelPosition = hotel.position
            local distance = #(playerCoords - vector3(hotelPosition.x, hotelPosition.y, hotelPosition.z))
            if distance <= 15.0 then
                DrawMarker(1, hotelPosition.x, hotelPosition.y, hotelPosition.z - 0.95, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 255, 255, 255, 100, 0, 0, 0, 0)
            end 
            if distance <= 2.0 then 
                if not enterSend then
                    enterSend = true
                    ESX.TextUI(Config.Locales["EnterRoom"], "info")
                end
                if IsControlJustPressed(0, 38) then
                    TriggerServerEvent("hotel:enterRoom", hotel.id)
                    Wait(250)
                    SetEntityCoords(PlayerPedId(), Config.HotelData.interrior.position)
                    SetEntityHeading(PlayerPedId(), Config.HotelData.interrior.heading)
                    TriggerServerEvent("hotel:loadCurrentRoom")

                end
            else
                if enterSend then
                    enterSend = false
                    ESX.HideUI()
                end
            end
        end
        if currentRoom ~= 0 then
            local player = PlayerPedId()
            local playerCoords = GetEntityCoords(player)
            local hotelPosition = Config.HotelData.interrior.position
            local distance = #(playerCoords - vector3(hotelPosition.x, hotelPosition.y, hotelPosition.z))
            if Config.HotelData.interrior.useMinibar then
                if #(playerCoords - Config.HotelData.interrior.minibarPosition) < 30.0 then 
                    DrawMarker(1, Config.HotelData.interrior.minibarPosition.x, Config.HotelData.interrior.minibarPosition.y, Config.HotelData.interrior.minibarPosition.z - 0.95, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 255, 255, 255, 100, 0, 0, 0, 0)
                    if #(playerCoords - Config.HotelData.interrior.minibarPosition) <= 2.0 then
                        if IsControlJustPressed(0, 38) then
                            OpenMinibar(hotel.id)
                        end
                    end
                end
            end

            if distance <= 15.0 then

                DrawMarker(1, hotelPosition.x, hotelPosition.y, hotelPosition.z - 0.95, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 255, 255, 255, 100, 0, 0, 0, 0)
            end 
            if distance <= 2.0 then 
                if not exitSend then
                    exitSend = true
                    ESX.TextUI(Config.Locales["ExitRoom"], "info")
                end
                if IsControlJustPressed(0, 38) then
                    TriggerServerEvent("hotel:exitRoom", hotel.id)
                    Wait(250)
                    ESX.TriggerServerCallback('hotel:getRoomPosition', function(x,y,z) 
                        if x == false then 
                            ESX.TextUI(Config.Locales["ErrorAdmin"], "error")
                            Wait(3500)
                            ESX.HideUI()
                        else
                            SetEntityCoords(PlayerPedId(), x,y,z)
                            TriggerServerEvent("hotel:loadCurrentRoom")
                        end
        
                    end, currentRoom)


                end
            else
                if exitSend then
                    exitSend = false
                    ESX.HideUI()
                end
            end
        end

    end
end)

CreateThread(function()
    RequestModel(GetHashKey(Config.HotelData.model))
    while not HasModelLoaded(GetHashKey(Config.HotelData.model)) do
      Wait(1)
    end

    local position = Config.HotelData.position
    ped =  CreatePed(4, GetHashKey(Config.HotelData.model),position.x,position.y,position.z, 3374176, false, true)
    SetEntityHeading(ped, Config.HotelData.heading)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
end)

local notificationSend = false
CreateThread(function()
    while true do
        Wait(1)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - Config.HotelData.position)
        if distance < 2.0 then
            if not notificationSend then
                notificationSend = true
                ESX.TextUI(Config.Locales["Receptionist"], "info")
            end
            if IsControlJustPressed(0,38) then
                openMainMenu()
            end
        else
            if notificationSend then
                notificationSend = false
                ESX.HideUI()
            end
        end
    end
end)



function openMainMenu()
    local mainMenu = NativeUI.CreateMenu(Config.Locales["NativeUITitle"], Config.Locales["NativeUIDescription"])
    _menuPool:Add(mainMenu)
    ESX.TriggerServerCallback('hotel:getCurrentHotel', function(hotelRoom,hotelPrice) 
        local noRoomItem = NativeUI.CreateItem(Config.Locales["NativeUINoRoomRented"], "~b~")
        local roomItemOwn = nil
        if hotelRoom == 0 then
            mainMenu:AddItem(noRoomItem)
        else
            roomItemOwn = NativeUI.CreateItem(Config.Locales["NativeUIRoomRented"], "~b~")
            roomItemOwn:RightLabel("~b~"..hotelRoom)
            mainMenu:AddItem(roomItemOwn)
            roomItemOwn.Activated = function(sender, item, index)
                openRoomManager(hotelRoom,hotelPrice)
            end

        end
        local placeholder = NativeUI.CreateItem('', '')
        mainMenu:AddItem(placeholder)
        ESX.TriggerServerCallback('hotel:getFreeRooms', function(freeRooms) 
            for _,value in ipairs(freeRooms) do
                local roomItem = NativeUI.CreateItem(Config.Locales["NativeUIRoomItem"] ..tostring(value.room), "~b~")
                roomItem:RightLabel("~b~>>>")
                mainMenu:AddItem(roomItem)
                roomItem.Activated = function(sender, item, index)
                    openRoomMenu(value.room, value.price)
                end
            end
            if #freeRooms == 0 then
                local noRoomItem = NativeUI.CreateItem(Config.Locales["NativeUINoFreeRooms"], "~b~")
                mainMenu:AddItem(noRoomItem)
            end

            _menuPool:RefreshIndex()
            _menuPool:MouseControlsEnabled(false)
            mainMenu:Visible(true)       
            menu = mainMenu 
        end)


    end)
end



function openRoomMenu(hotelRoom,price)
    local retval = KeyboardInput(Config.Locales["InputConfirmRenting"]:format(tostring(hotelRoom), tostring(price)), "", 7)
    menu:Visible(false)
    menu = {}
    if retval == nil then 
        ESX.TextUI(Config.Locales["InputConfirmRentingFalseText"], "error") 
        Wait(3500)
        ESX.HideUI()
        return
    end
    if string.lower(retval) == "confirm" then
        ESX.TriggerServerCallback('hotel:rentRoom', function(data) 
            if data == "success" then
                print('Success')
                ESX.TextUI(Config.Locales["RoomRentingSuccessfull"]:format(hotelRoom), "success")
                TriggerServerEvent("hotel:load")
                TriggerServerEvent("hotel:loadCurrentRoom")
                Wait(3500)
                ESX.HideUI()
            elseif data == "owned" then
                print('Owned')
                ESX.TextUI(Config.Locales["RoomRentingError"], "error")
                Wait(3500)
                ESX.HideUI()
            elseif data == "money" then
                print('Money')
                ESX.TextUI(Config.Locales["RoomRentingMoneyError"], "error")
                Wait(3500)
                ESX.HideUI()
            end

        end,hotelRoom,price)
    else
        ESX.TextUI(Config.Locales["InputConfirmRentingFalseText"], "error")
        Wait(3500)
        ESX.HideUI()
    end
end

function OpenMinibar(hotelroom)
    local minibarMenu = NativeUI.CreateMenu(Config.Locales["NativeUIRoomItem"] ..tostring(hotelroom), Config.Locales["RoomMinibarWelcome"])
    _menuPool:Add(minibarMenu)
    ESX.TriggerServerCallback('hotel:getMinibar', function(minibar) 
        for _, value in pairs(minibar) do
            local minibarItem = NativeUI.CreateItem(value.label, "~b~")
            local zero = (value.amount == 0)
            local color = (zero and "~r~" or "~g~")
            minibarItem:RightLabel(color..value.amount)
            minibarMenu:AddItem(minibarItem)
            minibarItem.Activated = function(sender, item, index)
                OpenMinibarItem(hotelroom,value.name,value.label,value.amount)
                minibarMenu:Visible(false)
            end

        end 

        _menuPool:RefreshIndex()
        _menuPool:MouseControlsEnabled(false)
        menu = minibarMenu 
        menu:Visible(false)
        menu = {}
        minibarMenu:Visible(true)       
    end, hotelroom)
end

function OpenMinibarItem(hotelroom,name,label,amount)
    local minibarCustomItem = NativeUI.CreateMenu(Config.Locales["NativeUIRoomItem"] ..tostring(hotelroom), Config.Locales["RoomMinibarWelcome"])
    _menuPool:Add(minibarCustomItem)

    local zero = (amount == 0)
    local color = (zero and "~r~" or "~g~")

    local ammountitem = NativeUI.CreateItem(Config.Locales["RoomMinibarAmount"], "~b~")
    ammountitem:RightLabel(color..amount)
    minibarCustomItem:AddItem(ammountitem)

    local removeItem = NativeUI.CreateItem("Take 1x " ..label, "~b~")
    minibarCustomItem:AddItem(removeItem)

    local placeholder = NativeUI.CreateItem('', '')
    minibarCustomItem:AddItem(placeholder)

    local backItem = NativeUI.CreateItem("Back", "~b~")
    minibarCustomItem:AddItem(backItem)
    backItem:RightLabel("~b~>>>")

    minibarCustomItem.OnItemSelect = function(sender, item, index)
        if item == removeItem then
            ESX.TriggerServerCallback('hotel:getMinibar', function(minibar) 
                for index,value in pairs(minibar) do
                    if value.name == name then
                        if value.amount > 0 then
                            TriggerServerEvent("hotel:removeMinibarItem",tonumber(hotelroom),name,label)
                            Wait(350)
                            minibarCustomItem:Visible(false)
                            OpenMinibar(hotelroom)
                        else
                            ESX.TextUI("There is no " ..label, "error")
                            Wait(3500)
                            ESX.HideUI()
                        end
                    end
                end
            end, hotelroom)
        end
        if item == backItem then
            minibarCustomItem:Visible(false)
            OpenMinibar(hotelroom)
        end

    end

    _menuPool:RefreshIndex()
    _menuPool:MouseControlsEnabled(false)
    menu = minibarCustomItem 
    minibarCustomItem:Visible(true)  

end

local developer = Config.HotelData.interrior.useMinibar

function openRoomManager(hotelRoom, price)
    local roomManagerMenu = NativeUI.CreateMenu("Room " ..tostring(hotelRoom), "Welcome to the room manager, select an option")
    _menuPool:Add(roomManagerMenu)

    local locateItem = NativeUI.CreateItem("Locate room", "~b~")
    roomManagerMenu:AddItem(locateItem)

    local leaveItem = NativeUI.CreateItem("Check out", "~b~")
    roomManagerMenu:AddItem(leaveItem)

    local minibarItem = NativeUI.CreateItem("Minibar managment", "~b~")

    if developer then
        minibarItem:RightLabel("~b~>>>")
        roomManagerMenu:AddItem(minibarItem)
    end
    -- Set the Badge to minibaritem 21


    local placeholder = NativeUI.CreateItem('', '')
    roomManagerMenu:AddItem(placeholder)

    local backItem = NativeUI.CreateItem("Back", "~b~")
    roomManagerMenu:AddItem(backItem)
    backItem:RightLabel("~b~>>>")


    local priceItem = NativeUI.CreateItem("Price:", "~b~")
    roomManagerMenu:AddItem(priceItem)
    priceItem:RightLabel("~b~$" ..tostring(price).. " / Payday")


    _menuPool:RefreshIndex()
    _menuPool:MouseControlsEnabled(false)
    menu:Visible(false)
    roomManagerMenu:Visible(true)       
    menu = roomManagerMenu 

    roomManagerMenu.OnItemSelect = function(sender, item, index)
        if item == backItem then
            menu:Visible(false)
            menu = {}
            openMainMenu()
        end
        if item == minibarItem then
            openMinibarMenu(hotelRoom, price)
        end
        if item == locateItem then
            ESX.TriggerServerCallback('hotel:getRoomPosition', function(x,y,z) 
                if x == false then 
                    ESX.TextUI("Error, please contact an administrator", "error")
                    Wait(3500)
                    ESX.HideUI()
                else
                    ESX.TextUI("Waypoint set!", "success")
                    SetNewWaypoint(x,y)
                    showDistance = true
                    CreateThread(function()
                        while showDistance do
                            Wait(1)
                            local playerPed = PlayerPedId()
                            local playerCoords = GetEntityCoords(playerPed)
                            local distance = #(playerCoords - vector3(x,y,z))
                            DrawText3D(x,y,z,"Distance to room: " ..tostring(math.floor(distance)).. "m")
                            if distance < 2.0 then
                                showDistance = false
                                ESX.TextUI("You are at the room", "success")
                                Wait(3500)
                                ESX.HideUI()
                            end
                        end
                    end)
                    Wait(3500)
                    ESX.HideUI()
                end

            end, hotelRoom)
        end
        if item == leaveItem then
            local retval = KeyboardInput('Enter "CONFIRM" to check out of the room ' ..tostring(hotelRoom), "", 7)
            menu:Visible(false)
            menu = {}
            if retval == nil then
                ESX.TextUI("You canceled the check-out process", "error")
                Wait(3500)
                ESX.HideUI()
                return
            end
            if string.lower(retval) == "confirm" then
                TriggerServerEvent('hotel:checkout', tonumber(hotelRoom))
                loaded = false
                hotel = {}
            else
                ESX.TextUI("You canceled the check-out process", "error")
                Wait(3500)
                ESX.HideUI()
            end
        end
    end

end

function openMinibarMenu(hotelroom,price)
    local minibarMenu = NativeUI.CreateMenu("Room " ..tostring(hotelroom), "Welcome to the minibar, select an option")
    _menuPool:Add(minibarMenu)
    ESX.TriggerServerCallback('hotel:getMinibar', function(minibar) 
        for _, value in pairs(minibar) do
            local item = NativeUI.CreateItem(value.label, "~b~")
            minibarMenu:AddItem(item)
            local zero = (value.amount == 0)
            local color = (zero and "~r~" or "~g~")
            item:RightLabel(color ..tostring(value.amount))
            item.Activated = function(sender, item, index)
                openMinibarItemmenu(hotelroom,price,value.label, value.cost, value.name)
            end
        end
        local placeholder = NativeUI.CreateItem('', '')
        minibarMenu:AddItem(placeholder)

        local backItem = NativeUI.CreateItem("Back", "~b~")
        minibarMenu:AddItem(backItem)
        backItem:RightLabel("~b~>>>")
        minibarMenu.OnItemSelect = function(sender, item, index)
            if item == backItem then
                menu:Visible(false)
                openRoomManager(hotelroom,price)
            end
        end
        _menuPool:RefreshIndex()
        _menuPool:MouseControlsEnabled(false)
        menu:Visible(false)
        minibarMenu:Visible(true)       
        menu = minibarMenu 
    end, hotelroom)

end

function openMinibarItemmenu(hotelroom,hotprice,label,price,name)
    local itemMenu = NativeUI.CreateMenu("Room " ..tostring(hotelroom), "Welcome to the minibar, select an option")
    _menuPool:Add(itemMenu)

    local buyOne = NativeUI.CreateItem("Buy 1x " ..label, "~b~")
    itemMenu:AddItem(buyOne)
    buyOne:RightLabel("~b~$" ..tostring(price))

    local buyTen = NativeUI.CreateItem("Buy 10x " ..label, "~b~")
    itemMenu:AddItem(buyTen)
    buyTen:RightLabel("~b~$" ..tostring(price*10))

    local placeholder = NativeUI.CreateItem('', '')
    itemMenu:AddItem(placeholder)

    local backItem = NativeUI.CreateItem("Back", "~b~")
    itemMenu:AddItem(backItem)
    backItem:RightLabel("~b~>>>")

    itemMenu.OnItemSelect = function(sender, item, index)
        if item == backItem then
            itemMenu:Visible(false)
            openMinibarMenu(hotelroom,hotprice)
        end
        if item == buyOne then
            itemMenu:Visible(false)
            TriggerServerEvent('hotel:buyMinibarItem', hotelroom, name, 1, price)
            Wait(350)
            openMinibarMenu(hotelroom,hotprice)

        end
        if item == buyTen then
            itemMenu:Visible(false)
            TriggerServerEvent('hotel:buyMinibarItem', hotelroom, name, 10, price*10)
            Wait(350)
            openMinibarMenu(hotelroom,hotprice)

        end
    end

    _menuPool:RefreshIndex()
    _menuPool:MouseControlsEnabled(false)
    menu:Visible(false)
    itemMenu:Visible(true)       
    menu = itemMenu 

end


function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)

	-- TextEntry		-->	The Text above the typing field in the black square
	-- ExampleText		-->	An Example Text, what it should say in the typing field
	-- MaxStringLenght	-->	Maximum String Lenght

	AddTextEntry('FMMC_KEY_TIP1', TextEntry) --Sets the Text above the typing field in the black square
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght) --Actually calls the Keyboard Input
	blockinput = true --Blocks new input while typing if **blockinput** is used

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do --While typing is not aborted and not finished, this loop waits
		Citizen.Wait(0)
	end
		
	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult() --Gets the result of the typing
		Citizen.Wait(500) --Little Time Delay, so the Keyboard won't open again if you press enter to finish the typing
		blockinput = false --This unblocks new Input when typing is done
		return result --Returns the result
	else
		Citizen.Wait(500) --Little Time Delay, so the Keyboard won't open again if you press enter to finish the typing
		blockinput = false --This unblocks new Input when typing is done
		return nil --Returns nil if the typing got aborted
	end
end

function DrawText3D(x,y,z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    ClearDrawOrigin()
end
