module GongBot
  module Request
    class Base
      include Logging

      attr_reader :data

      def initialize(data)
        @data = data
      end

      # Method stub
      def execute; end
    end
  end
end