# Mirow-Hotels
This script is only working with esx-legacy. If you use an older version you need to rewrite it.
You need to have oxmysql and NativeUILuaReloaded.
![image](https://user-images.githubusercontent.com/95571243/191331035-ec320b1a-d288-49bf-9c2d-1e65bcd3f8d4.png)
Thats the config: You can set the position,heading,model its for the interaction NPC. The interrior is were you get teleported when you enter the room.
You dont need to change Minibar because its a feature that is WIP and will be comming soon. If you have any Issues open a "Issue" or if you know how to code and fixed it
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
Have fun!
