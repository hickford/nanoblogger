require './nano.rb'

dbconfig = YAML.load(File.read('config/database.yml'))
environment = ENV['DATABASE_URL'] ? 'production' : 'development'
Nano::Models::Base.establish_connection dbconfig[environment]

Nano.create

run Nano
