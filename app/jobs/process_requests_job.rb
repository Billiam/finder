class ProcessRequestsJob
  include Logging

  def self.fetch_requests
    requests = []

    begin
      request = Request.ready.sort_by(created_at: :desc).find_and_modify({ "$set" => { status: 'processing'}}, new: true)
      break if request.nil?

      requests << request if request
    end until requests.length == 100

    requests
  end

  def requests
    @requests ||= self.class.fetch_requests
  end

  def work
    #convert messages array to author => message
    request_data = Hash[requests.map{ |m| [m.name, m.search] } ]

    loggy.debug "Parsing #{requests.length} requests"

    # map requests to hash of username => geocoded info
    addresses = Mapquest.geocode_coarse(request_data).reject { |k, v| v.nil? }

    #fetch values for request
    results = addresses.map do |user, data|
      point = Point.find_or_initialize_by(name: user)

      point.assign_attributes(
        city:     data.city,
        county:   data.county,
        state:    data.state,
        country:  data.country,
        location: { lat: data.lat, lng: data.long },
      )

      loggy.warn "Invalid point: #{point.errors.full_messages}" unless point.valid?

      point
    end

    loggy.debug "Inserting #{results.length} points"
    Point.bulk_upsert results

    requests.each(&:delete)
  end
end