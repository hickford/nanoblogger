Nanoblogger
=========

A microblogging web application.

Pusher credentials
---------

To run the app locally `config/environments/development.rb` must be created containing pusher credentials

    require 'pusher'

    Pusher.app_id = 'xxxx'
    Pusher.key    = 'xxxxxxxxxxxxxxxxxxxx'
    Pusher.secret = 'xxxxxxxxxxxxxxxxxxxx'
 
On Heroku, the pusher add-on handles the credentials.

