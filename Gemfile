source 'https://rubygems.org'
ruby "1.9.3"

# Server requirements
# gem 'thin' # or mongrel
# gem 'trinidad', :platform => 'jruby'

# Optional JSON codec (faster performance)
# gem 'oj'

# Project requirements
gem 'rake'

# Component requirements
gem 'bcrypt-ruby', :require => 'bcrypt'
gem 'erubis', '~> 2.7.0'
gem 'mongoid', '~> 3.0.0'
gem "mongoid_geospatial", "~> 2.8.2"

gem 'snoo', require: false
gem 'httparty', require: false
gem 'clockwork', require: false

#required to resolve mongoid geospatial vs padrino dependencies
gem "activesupport", "~> 3.2.15", require: false


gem "resque", "~> 1.25.1", require: false

# Test requirements
group :development, :test do
  gem 'rspec'
  gem 'rack-test', :require => 'rack/test'
end

# Padrino Stable Gem
gem 'padrino', '0.11.4'

# Or Padrino Edge
# gem 'padrino', :github => 'padrino/padrino-framework'

# Or Individual Gems
# %w(core gen helpers cache mailer admin).each do |g|
#   gem 'padrino-' + g, '0.11.4'
# end