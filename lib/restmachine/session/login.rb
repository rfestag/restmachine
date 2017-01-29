module Restmachine
  module Session
    class Login < SessionEndpoint
      def handle_request
        credentials = login
        if credentials
          authenticator.create_session credentials, response, ttl: ttl
        end
        return credentials
      end
      def ttl
        nil
      end
    end
  end
end
