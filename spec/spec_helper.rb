PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)

require 'simplecov'
require 'coveralls'
require 'vcr'
require 'webmock/rspec'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
]
SimpleCov.start

require File.expand_path(File.dirname(__FILE__) + "/../config/boot")

FactoryGirl.definition_file_paths = [
    File.join(Padrino.root, 'spec', 'factories')
]

FactoryGirl.find_definitions

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
  conf.include FactoryGirl::Syntax::Methods
  conf.extend VCR::RSpec::Macros

  # Create indices for each model
  conf.before(:suite) do
    Mongoid.models.each(&:create_indexes)
  end

  # Clean/Reset Mongoid DB prior to running each test.
  conf.before(:each) do
    Mongoid::Sessions.default.collections.select {|c| c.name !~ /system/}.each {|c| c.find.remove_all}
  end
end

Dir["./spec/support/**/*.rb"].sort.each {|f| require f}

def app(app = nil, &blk)
  @app ||= block_given? ? app.instance_eval(&blk) : app
  @app ||= Padrino.application
end
