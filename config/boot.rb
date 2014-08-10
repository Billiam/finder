# Defines our constants
PADRINO_ENV  = ENV['PADRINO_ENV'] ||= ENV['RACK_ENV'] ||= 'production'  unless defined?(PADRINO_ENV)
PADRINO_ROOT = File.expand_path('../..', __FILE__) unless defined?(PADRINO_ROOT)

# Load our dependencies
require 'rubygems' unless defined?(Gem)
require 'bundler/setup'

Bundler.require(:default, PADRINO_ENV)


app_env = Padrino.root('.env')
if File.exists?(app_env)
  require 'dotenv'
  Dotenv.load
end

##
# ## Enable devel logging
#
# Padrino::Logger::Config[:development][:log_level]  = :devel
# Padrino::Logger::Config[:development][:log_static] = true
#
# ## Configure your I18n
#
# I18n.default_locale = :en
#
# ## Configure your HTML5 data helpers
#
# Padrino::Helpers::TagHelpers::DATA_ATTRIBUTES.push(:dialog)
# text_field :foo, :dialog => true
# Generates: <input type="text" data-dialog="true" name="foo" />
#
# ## Add helpers to mailer
#
# Mail::Message.class_eval do
#   include Padrino::Helpers::NumberHelpers
#   include Padrino::Helpers::TranslationHelpers
# end

##
# Add your before (RE)load hooks here
#
Padrino.before_load do
  require 'will_paginate'
  require 'will_paginate_mongoid'
  require 'will_paginate/view_helpers/sinatra'
  include WillPaginate::Sinatra::Helpers

  Padrino.set_load_paths Padrino.root('service'), Padrino.root('app/jobs')
  Padrino.require_dependencies "#{Padrino.root}/config/initializers/**/*.rb"
end

##
# Add your after (RE)load hooks here
#
Padrino.after_load do
end

Padrino.load!
