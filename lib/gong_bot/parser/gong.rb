module GongBot::Parser
  module Gong
    extend self

    def from_messages(messages)
      user_data(messages)
    end

    protected
    def user_data(messages)
      messages.map do |m|
        {
            username: m[:author],
            date:     m[:date],
        }
      end
    end
  end
end