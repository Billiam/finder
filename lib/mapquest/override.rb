module Mapquest
  module Overrider
    module Locations
      COUNTRIES = {
        'Australia' => 'AU',
        'Norway'    => 'NO',
        'Argentina' => 'AR',
      }
    end

    extend self

    def fix(location)
      Locations::COUNTRIES.has_key?(location) ? "{country: #{Locations::COUNTRIES[location]}}" : location
    end
  end
end
