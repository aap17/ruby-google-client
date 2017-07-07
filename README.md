# ruby-google-client

##Ruby on Rails клиент для Google In-app billing API
Есть 2 варианта работы:
**A.** [Простая проверка встроенных покупок](https://github.com/aap17/ruby-google-client/blob/master/rubygoogleinapp.rb).
**B.** [Проверка с кэшированием запросов](https://github.com/aap17/ruby-google-client).
Подробное описание происходящего ищите [в статье для журнала Хакер](https://xakep.ru/author/pahomov/).

## About

Sample for using Google In-app Billing API on a server side with Ruby on Rails. It can check consumable payments and subscriptions
inside your Android application. Works with new Google API Library, version *0.11* and above.

### Prerequisites

You need to create own service account. Good HowTo [here](https://stackoverflow.com/a/35138885).

Two options:

**A.** [Simple checking demo](https://github.com/aap17/ruby-google-client/blob/master/rubygoogleinapp.rb). Just dumb payments checking.
**B.** [Checking with caching](https://github.com/aap17/ruby-google-client). Google limit free requests to 200k/day.
So it's nessasary caching to avoid repeated requests.I've made simple DB, it's oblioviosly not the best but works.

Enjoy!
