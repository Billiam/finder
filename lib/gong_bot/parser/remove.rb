module GongBot::Parser
  module Remove
    extend self

    def from_messages(messages)
      messages.map { |m| m[:author] }
    end
  end
end