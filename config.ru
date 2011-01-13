#!/usr/bin/ruby
environment = ENV['DATABASE_URL'] ? 'production' : 'development'

if environment == 'development'
    require './config/environments/development.rb'
end

require './nano.rb'

dbconfig = YAML.load(File.read('config/database.yml'))
Nano::Models::Base.establish_connection dbconfig[environment]
Nano.create

run Nano

