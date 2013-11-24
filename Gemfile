source 'https://rubygems.org'
# Server requirements
# gem 'thin' # or mongrel
# gem 'trinidad', :platform => 'jruby'

# Optional JSON codec (faster performance)
# gem 'oj'

# Project requirements
gem 'rake'

gem 'newrelic_moped', require: false
gem 'newrelic_rpm', require: false

# Component requirements
gem 'bcrypt-ruby', :require => 'bcrypt'
gem 'erubis', '~> 2.7.0'
gem 'mongoid', '~> 3.1.5'
gem "mongoid_geospatial", "~> 2.8.2"

gem 'snoo', require: false
gem 'httparty', require: false
#required to resolve mongoid geospatial vs padrino dependencies
gem "activesupport", "~> 3.2.15", require: false
gem "csso-rails", require: false
gem 'sucker_punch', '~> 1.0'
gem 'clockwork',  '~> 0.7.0'
gem 'daemons', '~> 1.1.9'

group :development do
  gem 'guard-rspec', require: false
end

group :test do
  gem 'simplecov', require: false
  gem 'coveralls', require: false
end

group :development, :test do
  gem 'rspec'
  gem "mongoid-rspec", "~> 1.9.0"
  gem 'factory_girl'
  gem 'rack-test', :require => 'rack/test'
end

# Padrino Stable Gem
gem 'padrino', '0.11.4'
gem "will_paginate_mongoid", "~> 2.0.1", require: false
gem "will_paginate-bootstrap", "~> 1.0.0", require: false

# Or Padrino Edge
# gem 'padrino', :github => 'padrino/padrino-framework'

# Or Individual Gems
# %w(core gen helpers cache mailer admin).each do |g|
#   gem 'padrino-' + g, '0.11.4'
# end