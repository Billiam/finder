class ProcessRequestsJob
  include Logging
  include Lockable

  lock_with :geocode_lock

  def self.fetch_requests
    requests = []

    begin
      request = Request.ready.order_by(created_at: :desc).find_and_modify({ "$set" => { status: 'processing' }}, new: true)
      break if request.nil?

      requests << request if request
    end until requests.length == 100

    requests
  end

  def requests
    @requests ||= self.class.fetch_requests
  end

  def run
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

      loggy.warn "Invalid point: #{point.attributes} - #{point.errors.full_messages}" unless point.valid?

      point
    end

    #remove invalid entries
    results.select!(&:valid?)

    loggy.debug "Inserting #{results.length} points"
    Point.bulk_upsert results

    requests.each(&:delete)
  end

  def work
    unless lock { run }
      loggy.warn "Geocoding already in progress"
    end
  end
end