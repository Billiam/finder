# Connection.new takes host and port.

host = 'localhost'
port = 27017

database_name = case Padrino.env
  when :development then 'al_finder_development'
  when :production  then 'al_finder_production'
  when :test        then 'al_finder_test'
end

# Use MONGO_URI if it's set as an environmental variable.
Mongoid::Config.sessions =
  if ENV['MONGO_URI']
    {default: {uri: ENV['MONGO_URI'] }}
  else
    {default: {hosts: ["#{host}:#{port}"], database: database_name}}
  end