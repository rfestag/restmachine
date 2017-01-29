module Restmachine
  module Session
    class Logout < SessionEndpoint
      def handle_request
        logout
        authenticator.destroy_session response
      end
    end
  end
end
