PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")


FactoryGirl.definition_file_paths = [
    File.join(Padrino.root, 'spec', 'factories')
]

FactoryGirl.find_definitions

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
  conf.include FactoryGirl::Syntax::Methods

  # Clean/Reset Mongoid DB prior to running each test.
  conf.before(:each) do
    Mongoid::Sessions.default.collections.select {|c| c.name !~ /system/}.each {|c| c.find.remove_all}
  end
end

Dir["./spec/support/**/*.rb"].sort.each {|f| require f}

# You can use this method to custom specify a Rack app
# you want rack-test to invoke:
#
#   app Speccy::App
#   app Speccy::App.tap { |a| }
#   app(Speccy::App) do
#     set :foo, :bar
#   end
#
def app(app = nil, &blk)
  @app ||= block_given? ? app.instance_eval(&blk) : app
  @app ||= Padrino.application
end
