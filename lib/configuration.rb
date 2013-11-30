module Configuration
  MAPQUEST_KEY   = ENV['MAPQUEST_KEY'] || 'mapquest_key'
  BOT_USERNAME   = ENV['BOT_USERNAME'] || '--bot_username'
  BOT_PASSWORD   = ENV['BOT_PASSWORD'] || 'bot_password'
  BOT_USERAGENT  = ENV['BOT_USERAGENT'] || 'Gongbot'
  LOG_LEVEL      = ENV['LOG_LEVEL'] || 'WARN'
  COMPILED       = ENV['COMPILED'] != 'false'
  CACHE          = ENV['CACHE'] != 'false'
  NEW_RELIC_KEY  = ENV['NEW_RELIC_LICENSE_KEY']
  SESSION_SECRET = ENV['SESSION_SECRET']
end