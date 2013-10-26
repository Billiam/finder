require 'httparty'

module Mapquest
  include Logging

  extend self
  include HTTParty

  #Override default query normalizer to allow sort order to be maintained
  query_string_normalizer QueryNormalizer::UNSORTED_NORMALIZER
  base_uri 'open.mapquestapi.com/geocoding/v1'

  def geocode_coarse(locations)
    # hash of user => geocoded address (or nil)
    addresses = geocode locations

    #get list of addresses to recode
    requery_list = {}

    addresses.each do |username, result|
      next if result.nil?
      if result.street_quality?
        requery_list[username] = result.formatted
        addresses[username] = nil
      end
    end

    addresses.merge! geocode(requery_list) unless requery_list.empty?

    addresses
  end

  def geocode(locations)
    loggy.debug %Q(Geocoding: #{locations.values.join("\n----\n")})

    #create username to nil hash to return
    results = Hash[locations.keys.zip()]

    # safe hash inversion
    # hash of unique location => [username....]
    query = locations.each_with_object({}) do |(key, value), query|
      next if value.nil?

      query[value] ||= []
      query[value] << key
    end

    # list of input addresses
    address_list = query.keys

    #send query
    response = get('/batch', query: { location: address_list, key: ENV['MAPQUEST_KEY'] })

    unless response.success?
      loggy.warn "Could not geocode addresses: #{response.code}"
      return results
    end

    #iterate over input and output addresses
    address_list.zip(response['results']).each do |input, output|
      next if output['locations'].empty?

      # retrieve usernames associated with unique input address
      usernames = query[input]

      #create a location result instances
      location = Result.new output['locations'].first

      #return result for username
      usernames.each { |u| results[u] = location }
    end

    results
  end
end