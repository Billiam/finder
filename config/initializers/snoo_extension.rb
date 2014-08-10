require 'snoo'
module Snoo
  # Account related methods, such as logging in, deleting the current user, changing passwords, etc
  #
  # @author (see Snoo)
  module Account
    # Log into a reddit account. You need to do this to use any restricted or write APIs
    #
    # @param username [String] The reddit account's username you wish to log in as
    # @param password [String] The password of the reddit account
    # @return [HTTParty::Response] The httparty request object.
    def log_in username, password
      login = post("/api/login", :body => {user: username, passwd: password, api_type: 'json'})
      errors = login['json']['errors']
      raise errors[0][1] unless errors.size == 0
      #override default behavior to also set reddit_session
      login_cookies = login.headers['set-cookie']
      session_cookies = login['json']['data']['cookie']
      set_cookies "reddit_session=#{session_cookies}; #{login_cookies}"
      @modhash = login['json']['data']['modhash']
      @username = username
      @userid = 't2_' + get('/api/me.json')['data']['id']
      return login
    end
  end
end
