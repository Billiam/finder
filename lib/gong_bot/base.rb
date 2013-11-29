require 'snoo'

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
      messages.reject { |m| !m.has_key?('data') || m['data']['was_comment'] }
    end

    def self.format_message message
      data = message['data']
      {
          author: data['author'],
          message: data['body'],
          date: Time.at(data['created_utc'])
      }
    end

    def run
      loggy.debug 'Starting gong bot'

      results = GongBot::Results.new inbox_requests

      loggy.debug 'Bot completed'

      results
    end

    def client
      @client ||= ::Snoo::Client.new({
        username: Configuration::BOT_USERNAME,
        password: Configuration::BOT_PASSWORD,
        useragent: Configuration::BOT_USERAGENT,
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
      messages = fetch_messages.map { |message| self.class.format_message message }
      self.class.partition_messages messages
    end

    def fetch_messages
      loggy.info 'Fetching info messages'

      messages = client.get_messages('unread', {
        mark: true,
        limit: 50
      })

      if messages.success?
        return self.class.filter_pms messages['data']['children']
      else
        loggy.warn "Unable to fetch messages, received #{messages.code}"
      end

      []
    end
  end
end
