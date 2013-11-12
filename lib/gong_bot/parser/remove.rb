module GongBot::Parser
  class Remove < Base
    def self.from_messages(messages)
      self.new messages.map { |m| m[:author] }
    end
  end
end