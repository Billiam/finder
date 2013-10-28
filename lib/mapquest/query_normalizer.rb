module Mapquest
  module QueryNormalizer
    UNSORTED_NORMALIZER = Proc.new do |query|
      Array(query).sort_by { |a| a[0].to_s }.map do |key, value|
        if value.nil?
          key.to_s
        elsif value.is_a?(Array)
          value.map {|v| "#{key}=#{URI.encode(v.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"}
        else
          ::HTTParty::HashConversions.to_params(key => value)
        end
      end.flatten.join('&')
    end
  end
end