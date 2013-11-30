module GongBot
  class Results
    attr_accessor :data

    def initialize(data)
      self.data = data
    end

    def registration
      @registration ||= Parser::Register.from_messages data[:registrations]
    end

    def gong
      @gong ||= Parser::Gong.from_messages data[:gongs]
    end

    def removal
      @removal ||= Parser::Remove.from_messages data[:remove]
    end
  end
end
