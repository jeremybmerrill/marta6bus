Marta Bus
---------

Marta's #6 bus route travels between Lindbergh Station and Inman Park Station, passing by Emory University. However, some southbound rush hour trips from Lindbergh short-turn at Emory; if you were wanting to go to Inman Park, you'd have to wait for the next bus. Unfortunately, the MARTA On The Go app doesn't have any way to show you an en-route bus's destination. Not knowing whether the next bus will take you home can be a problem for #6 bus riders; they can end up waiting at the stop for a long time and, at rush hour, the On The Go app is rendered basically useless by this problem.

This application is meant to be a stopgap solution. Bus riders can text a special number to receive two pieces of information about each southbound en-route #6 buses: the scheduled end point of the bus route and the vehicle number. That vehicle number can be cross-correlated with the data from the MARTA On The Go app for bus realtime(-ish) locations and also with the number on a physical bus, once it arrives.

If you were to want to set this up yourself, you'll have to do these setup steps:

1. download MARTA's current GTFS dataset. (link TK)
2. install [GTFSDB](https://github.com/OpenTransitTools/gtfsdb) and its dependencies (`pip install sqlalchemy geoalchemy`)
3. Then load the GTFS data into a Postgresql database called `marta` with this command: `gtfsdb-load --database_url postgres:///marta  google_transit.zip` (You'll have to create the database first, with `createdb marta`)
4. Get Twilio creds (a SID, an Auth Token) and a phone number, and put them in a file called `secrets.yaml`, basing it off of the example in `secrets.yaml.example`.
5. run `listen.rb`.
5. TK TK. Twilio webhooks, ngrok, etc.

At any given time, you can "simulate" the response a rider texting the service would get by running `ruby make_message.rb`. Or, to send a text with the results, run `ruby make_message.rb | ruby send_sms.rb +14045551234`, substituting your destination number for the one in the example.

This could probably be easily extended to cover other MARTA bus routes that short-turn at rush hour.