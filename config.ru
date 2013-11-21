#!/usr/bin/env rackup
# encoding: utf-8

# This file can be used to start Padrino,
# just execute it from the command line.

require File.expand_path("../config/boot.rb", __FILE__)
use Rack::ExclusionDeflater, :exclude => proc { |env|
  env['REQUEST_PATH'] =~ /\.(jpg|jpeg|png|gif)\z/
}
use Rack::Static,
    :urls => ["/build", "/javascripts", "/stylesheets", "/img"],
    :root => "public",
    :header_rules => [
       [:all, {'Cache-Control' => 'public, max-age=31536000'}],
     ]
run Padrino.application
