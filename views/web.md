Spitcast/Twilio Demo
-------
This is a [Twilio](http://www.twilio.com) demo that uses the totally excellent [Spitcast API](http://www.spitcast.com/api/docs/) to give you some surf predictions via SMS.

Right now it's hard coded to only show spots in San Francisco, but could be extended to anywhere the Spitcast API covers.

This web page isn't much fun. To try out the app, send an SMS to **(617) 3-SWELLS**.

Text "spots" to get a list of the surf spots in SF and their IDs.

Text a spot ID (for example "113") to get conditions at that spot for the next four hours.

This is built using [Sinatra](http://www.sinatrarb.com), hosted on [Heroku](http://spitcast-sms.herokuapp.com/), and uses [memcachier](http://memcachier.com/)/[dalli](https://github.com/mperham/dalli) to cache responses. You can find the code for this project on my [Github](https://github.com/akjordan/Twilio-Demo-Surf).