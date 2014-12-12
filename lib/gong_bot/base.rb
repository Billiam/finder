require 'redd'

module GongBot
  class Base
    include Logging

    def self.is_remove? message
      (message.strip =~ /\A(remove|delete)\z/i).present?
    end

    def self.is_gong? message
      (message.strip =~ /\A!*g+o+n+g+[!1]*\z/i).present?
    end

    def self.partition_messages messages
      results = {
        registrations: [],
        gongs: [],
        remove: [],
      }

      messages.each do |m|
        if is_gong? m[:message]
          results[:gongs] << m
        elsif is_remove? m[:message]
          results[:remove] << m
        else
          results[:registrations] << m
        end
      end

      results
    end

    def self.filter_pms messages
      messages.reject(&:was_comment?)
    end

    def self.format_message message
      {
        author: message.author,
        message: message.body,
        date: message.created
      }
    end

    def run
      loggy.debug 'Starting gong bot'

      results = GongBot::Results.new inbox_requests

      loggy.debug 'Bot completed'

      results
    end

    def client
      @client ||= ::Redd::Client::Authenticated.new_from_credentials(
        Configuration::BOT_USERNAME,
        Configuration::BOT_PASSWORD,

        user_agent: Configuration::BOT_USERAGENT,
      )
    end

    def inbox_requests
      messages = fetch_messages.map { |message| self.class.format_message message }
      self.class.partition_messages messages
    end

    def read messages
      return unless messages.present?

      loggy.debug "Marking #{messages.count} as read"

      client.mark_many_read messages
    end

    def fetch_messages
      loggy.info 'Fetching info messages'

      messages = client.messages('unread', true, {
        limit: 25
      })

      if messages
        filtered_messages = self.class.filter_pms messages
        self.read filtered_messages
        return filtered_messages
      else
        loggy.warn "Unable to fetch messages"
      end

      []
    end
  end
end
