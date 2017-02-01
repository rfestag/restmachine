module Restmachine
  module Session
    class Login < SessionEndpoint
      def handle_request
        credentials = login
        if credentials
          opts = xsrf_enabled ? {xsrf: xsrf_token, exp: xsrf_expiration, ttl: xsrf_ttl} : {ttl: ttl}
          authenticator.create_session credentials, response, opts
        end
        return credentials
      end
      def ttl
        xsrf_ttl
      end
    end
  end
end
