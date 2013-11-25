module GongBot::Parser
  module Register
    extend self

    def from_messages(messages)
      user_data(messages)
    end

    protected
    def user_data(messages)
      messages.map do |message|
        {
            name:   message[:author],
            pm:     true,
            search: message[:message].strip,
        }
      end
    end
  end
end