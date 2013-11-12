module Mapquest
  class Result
    module Location
      COUNTRY = 'adminArea1'
      STATE   = 'adminArea3'
      COUNTY  = 'adminArea4'
      CITY    = 'adminArea5'

      def self.locations
        [CITY, COUNTY, STATE, COUNTRY]
      end

      def self.quality
        %w(COUNTRY STATE COUNTY CITY ZIP ZIP_EXTENDED)
      end
    end

    attr_accessor :result

    def initialize(result)
      self.result = result
    end

    def street_quality?
      ! Location.quality.include? self.result['geocodeQuality']
    end

    def formatted
      Location.locations.map { |loc| self.result[loc] }.reject(&:empty?).join(', ')
    end

    def lat
      self.result['latLng']['lat']
    end

    def long
      self.result['latLng']['lng']
    end

    #define state, country, methods
    Location.constants(false).each do |c|
      define_method :"#{c.downcase}" do
        val = self.result[Location.const_get(c)]
        val == '' ? nil : val
      end
    end
  end
end

