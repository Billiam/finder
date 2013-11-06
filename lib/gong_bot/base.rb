require 'snoo'

module GongBot
  class Base
    include Logging

    def self.is_gong? message
      message.strip =~ /\A!*g+o+n+g+[!1]*\z/i
    end

    def self.parse_messages messages
      results = {
        registrations: [],
        gongs: [],
      }

      messages.each do |m|
        if is_gong? m[:message]
          results[:gongs] << m
        else
          results[:registrations] << m
        end
      end

      results
    end

    def run
      loggy.debug 'Starting gong bot'

      data = inbox_requests

      register = Request::Register.new(data[:registrations])
      register.execute

      gong = Request::Gong.from_messages data[:gongs]
      gong.execute

      if data[:registrations].length < 25
        register.results.each { |result| notify_registration result }
      end
    end

    def client
      @client ||= ::Snoo::Client.new({
        username: ENV['BOT_USERNAME'],
        password: ENV['BOT_PASSWORD'],
        useragent: 'AL Finder Prototype',
      })
    end

    def logged_in?
      begin
        self.client.logged_in?
        true
      rescue Snoo::NotAuthenticated => e
        false
      end
    end

    def inbox_requests
      messages = []

      fetch_messages.each do |m|
        data = m['data']
        next if data['was_comment']

        messages << { author: data['author'], message: data['body'], date: Time.at(data['created_utc']) }
      end

      self.class.parse_messages messages
    end

    def fetch_messages
      loggy.info 'Fetching info messages'

      messages = client.get_messages('unread', {
        #mark: true,
        limit: 50
      })

      if messages.success?
        return messages['data']['children']
      else
        loggy.warn "Unable to fetch messages, received #{messages.code}"
      end

      []
    end

    def notify_registration(data)
      if data[:result]
        message = "Ok, I've set your location to #{data[:result][:address]}!"
      else
        quoted_message = '>' + data[:message].split("\n").join("\n>")
        message = "Sorry, I could not find that location :\n#{quoted_message}"
      end

      result = self.client.send_pm data[:user], 'AL Finder', message

      if ! result.success?
        loggy.warn "Unable to create a new private message, received #{result.code}"
      elsif result['json']['errors']
        loggy.warn "PM Send resulted in errors. #{result['json']['errors']}"
      end

      result
    end
  end
end
