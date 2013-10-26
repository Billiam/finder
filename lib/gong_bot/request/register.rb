module GongBot::Request
  class Register < Base

    def initialize(data)
      super
    end

    def execute
      Finder.register parsed_data
    end

    def results
      parsed_data
      @results
    end

    protected

    def parsed_data
      @parsed_data ||= begin
        #convert messages array to author => message
        requests = Hash[self.data.map{ |m| [m[:author], m[:message]] } ]

        # map requests to hash of username => geocoded info
        addresses = Mapquest.geocode_coarse(requests).reject { |k, v| v.nil? }

        geocoded = {}

        #fetch values for request
        addresses.each do |author, data|
          geocoded[author] = {
            username: author,
            city:     data.city,
            county:   data.county,
            state:    data.state,
            country:  data.country,
            long:     data.long,
            lat:      data.lat,
            address:  data.formatted
          }
        end

        @results = requests.map do |user, message|
          { user: user, message: message, result: geocoded[user] }
        end

        geocoded.values
      end
    end
  end
end