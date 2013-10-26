require 'httparty'

module Finder
  extend self
  include HTTParty

  base_uri ENV['FINDER_URL']

  def request(uri, users)
    return true if ENV['FINDER_URL'].empty? || users.empty

    response = post(uri,
      body: users.to_json,
      headers: {
        'Content-Type' => 'application/json'
      }
    )

    response.success?
  end

  def gong(users)
    request '/gongs', users
  end

  def register(users)
    request '/users', users
  end
end