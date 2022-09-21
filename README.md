# Mirow-Hotels
This script is only working with esx-legacy. If you use an older version you need to rewrite it.
You need to have oxmysql and NativeUILuaReloaded.

![image](https://user-images.githubusercontent.com/95571243/191331035-ec320b1a-d288-49bf-9c2d-1e65bcd3f8d4.png)

Thats the config: You can set the position,heading,model its for the interaction NPC. The interrior is were you get teleported when you enter the room.
At the point minibar you can select what items you can buy and at amount what the default amount in the bar is. If you have any Issues open a "Issue" or if you know how to code and fixed it
then open a pull request.
# Preview
https://youtu.be/OhnRHXrRphI
# Installation
To install the Hotel script, you have to import the hotels.sql.
To create a hotel you need to do this command:
- /createroom roomnumber (Unique!) price (pro payday)
Then you have to go to the es_extended/server/paycheck lua and add this part:
``        TriggerEvent('hotel:payCheck', xPlayer.source)``

![image](https://user-images.githubusercontent.com/95571243/191331665-75d83615-31cf-467e-8a15-fdcee5149a36.png)

# Minibar Preview
![image](https://user-images.githubusercontent.com/95571243/191578929-c872bd4e-ed2a-4561-b5f3-2a59e39d03e6.png)
![image](https://user-images.githubusercontent.com/95571243/191578961-b4b12d12-66ae-4523-b2db-e302edfde281.png)
![image](https://user-images.githubusercontent.com/95571243/191579060-fa2b1e60-0cd6-4675-8c29-998324e51229.png)
![image](https://user-images.githubusercontent.com/95571243/191579093-8dc6d26e-861a-4bd2-bb37-48c62a721351.png)


Have fun!
