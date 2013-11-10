module GongBot::Parser
  class Base
    include Logging

    attr_reader :data

    def results
      @data
    end

    def initialize(data)
      @data = data
    end
  end
end