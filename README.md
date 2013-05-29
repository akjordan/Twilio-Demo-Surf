Twilio-Demo-Surf
================

A Twilio demo that uses the totally excellent [Spitcast API](http://www.spitcast.com/api/docs/) to give you some surf predictions via SMS.

Right now it's hard coded to be mosty useful to San Francisco locals.

To try it out, point a Twilio SMS URL at http://spitcast-sms.herokuapp.com/

Text "spots" to get a list of the surf spots in SF and their IDs.

Text a spot ID to get conditions at that spot for the next four hours.

This is built using Sinatra, hosted on [Heroku](http://spitcast-sms.herokuapp.com/), and uses [memcachier](http://memcachier.com/) and [dalli](https://github.com/mperham/dalli) to cache responses. Fork the project [here](https://github.com/akjordan/Twilio-Demo-Surf).