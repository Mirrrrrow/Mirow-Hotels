Config = {
    HotelData = {
        position = vector3(574.7357, -1743.5320, 28.2782),
        heading = 332.2069,
        model = "a_m_m_ktown_01",
        interrior = {
            position = vector3(151.3126, -1008.0188, -99.0000),
            heading = 2.7329,
            useMinibar = true, --Enable Minibar?
            minibarPosition = vector3(151.2918, -1003.5375, -98.9999),
        },
        MiniBar = {
            {
                name = "bread",
                label = "Bread",
                cost = 3,
                amount = 2, -- Start Amount
            },
            {
                name = "petrol",
                label = "Oil",
                cost = 80,
                amount = 0, -- Start Amount
            },
            {
                name = "water",
                label = "Wasser",
                cost = 1,
                amount = 0, -- Start Amount
            }
        }
    },
    Locales = {
        ["EnterRoom"] = "Press ~g~E~s~, to enter the room",
        ["ExitRoom"] = "Press ~g~E~s~, to exit the room",
        ["ErrorAdmin"] = "Error, please contact an administrator",        
        ["Receptionist"] = "Press g~E~s~, to talk to the receptionist",      
        ["NativeUITitle"] = "Hotel",
        ["NativeUIDescription"] = "Welcome to the hotel, please select an option!",
        ["NativeUINoRoomRented"] = "No room rented",
        ["NativeUIRoomRented"] = "Room rented:",
        ["NativeUIRoomItem"] = "Room ",
        ["NativeUINoFreeRooms"] = "No room available",
        ["InputConfirmRenting"] = "Enter 'CONFIRM' to rent the Room %s for $%s / Payday",
        ["InputConfirmRentingFalseText"] = "You didn't enter the correct text!",
        ["RoomRentingSuccessfull"] = "You rented the room %s!",
        ["RoomRentingError"] = "You can't rent this room!",
        ["RoomRentingMoneyError"] = "You don't have enough money to rent this room!",
        ["RoomMinibarWelcome"] = "Welcome to the minibar, please select an item!",
        ["RoomMinibarAmount"] = "Amount:"


    }
}
