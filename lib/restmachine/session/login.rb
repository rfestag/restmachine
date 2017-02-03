module Restmachine
  module Session
    class Login < SessionEndpoint
      def allowed_methods
        %w(GET POST)
      end
      def handle_request
        generate_xsrf_token
        credentials = login
        if credentials
          opts = {xsrf: xsrf_token, exp: xsrf_expiration, ttl: xsrf_ttl}
          authenticator.create_session credentials, response, opts
        end
        return credentials
      end
    end
  end
end
