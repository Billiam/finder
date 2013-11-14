module Padrino
  module Cache
    module Store
      ##
      # Moped Cache Store
      #
      class Moped < Base
        ##
        # Initialize Moped adapter store with client connection and optional username and password.
        #
        # @param [Hash] opts options to pass into moped connection
        # @option options [Moped::Session] :session Preconfigured session (optional)
        # @option options [String, Array] :host host:port list
        # @option options [String] :database
        # @option options [Boolean] :capped
        # @option options [Symbol] :collection
        # @option options [Integer] :size
        # @option options [Integer] :max
        #
        # @example
        #   Padrino.cache = Padrino::Cache::Store::Moped.new(::Moped::Session.new(['127.0.0.1:27017']).use('padrino'), :username => 'username', :password => 'password', :size => 64, :max => 100, :collection => 'cache')
        #   # or from your app
        #   set :cache, Padrino::Cache::Store::Moped.new(::Moped::Session.new(['127.0.0.1:27017']).use('padrino'), :username => 'username', :password => 'password', :size => 64, :max => 100, :collection => 'cache')
        #   # you can provide a marshal parser (to store ruby objects)
        #   set :cache, Padrino::Cache::Store::Moped.new(::Moped::Session.new(['127.0.0.1:27017']).use('padrino'), :parser => :marshal)
        #
        def initialize(options={})
          @options = {
              :capped => true,
              :collection => :cache,
              :size => 64,
              :max => 100
          }.merge(options)
          @session = options[:session] ||
            begin
              host = Array(options.delete(:host) || '127.0.0.1:27017')
              user = options.delete(:user)
              password = options.delete(:password)
              ::Moped::Session.new(hosts)
            end
          @db = @session.use(options.delete(:database) || 'padrino')
          @session.login(username, password) if user && password
          @collection = get_collection
          # create expiration index
          @collection.indexes.create({expires: 1} , {:expireAfterSeconds => 0})
          super(options)
        end

        ##
        # Return the value for the given key.
        #
        # @param [String] key
        #   cache key
        #
        # @example
        #   MyApp.cache.get('records')
        #
        def get(key)
          @collection.find(:_id => key).first.try(:[], 'value')
        end

        ##
        # Set or update the value for a given key and optionally with an expire time.
        # Default expiry is Time.now + 86400s.
        #
        # @param [String] key
        #   cache key
        # @param value
        #   value of cache key
        # @param [Hash] opts value storage options
        # @option options [Integer] :expires_in Expiration time in seconds
        # @example
        #   MyApp.cache.set('records', records)
        #   MyApp.cache.set('records', records, :expires_in => 30) # => 30 seconds
        #
        def set(key, value, opts = nil)
          doc = { :_id => key, value: value }
          doc[:expires] = mongo_time(get_expiry(opts)) if opts[:expires_in].present?
          @collection.find(:_id => key).upsert doc
        end

        ##
        # Delete the value for a given key.
        #
        # @param [String] key
        #   cache key
        #
        # @example
        #   MyApp.cache.delete('records')
        #
        def delete(key)
          unless @options[:capped]
            @collection.find(:_id => key).remove
          end
        end

        ##
        # Reinitialize your cache.
        #
        # @example
        #   # with: MyApp.cache.set('records', records)
        #   MyApp.cache.flush
        #   MyApp.cache.get('records') # => nil
        #
        def flush
          @collection.drop
          @collection = get_collection
        end

        private

        def mongo_time(timestamp)
          Time.at(timestamp, 0).utc
        end

        def get_collection
          if !@session.collection_names.include?(@options[:collection].to_s) && @options[:capped]
            @session.command(
              create: @options[:collection].to_s,
              capped: true,
              size: @options[:size]*1024**2,
              max: @options[:max]
            )
          end
          @session[@options[:collection]]
        end
      end
    end
  end
end