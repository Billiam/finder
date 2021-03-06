require 'vcr'

VCR.config do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.stub_with :webmock
  c.ignore_localhost = true
  c.default_cassette_options = { :record => :none }
  c.filter_sensitive_data('<MAPQUEST_API_KEY>') { URI.encode(Configuration::MAPQUEST_KEY) }
end