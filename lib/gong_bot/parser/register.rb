module GongBot::Parser
  class Register < Base
    def self.user_data(messages)
      messages.map do |message|
        {
          name:   m[:author],
          pm:     true,
          search: message[:message],
        }
      end
    end

    def self.from_messages(messages)
      self.new user_data(messages)
    end
  end
end