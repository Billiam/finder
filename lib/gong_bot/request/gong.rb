module GongBot::Request
  class Gong < Base
    def self.user_data(messages)
      messages.map do |m|
        {
          username: m[:author],
          date:     m[:date],
        }
      end
    end

    def self.from_messages(messages)
      self.new user_data(messages)
    end


    def execute
      Finder.gong data if data
    end
  end
end