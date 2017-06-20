# ruby-google-client

## About

Sample for using Google In-app Billing on a server side with Ruby on Rails. It can check consumable payments and subscriptions
inside your Android application. Works with new Google API Library, version *0.11* and above.

### Prerequisites

You need to create own service account. Good HowTo [here](https://stackoverflow.com/a/35138885).

Two options:

**A.** [Simple checking demo](https://github.com/aap17/ruby-google-client/blob/master/rubygoogleinapp.rb). Just dumb payments checking.
**B.** [Checking with caching](https://github.com/aap17/ruby-google-client). Google limit free requests to 200k/day. So it's nessasary caching to avoid repeated requests.
I've made simple DB, it's oblioviosly not the best but works.

![DB scheme ](db.png)

Enjoy!


