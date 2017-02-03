module Restmachine
  module Session
    class Logout < SessionEndpoint
      def allowed_methods
        %w(DELETE)
      end
      def delete_resource
        logout
        authenticator.destroy_session response
        generate_xsrf_token
        true
      end
    end
  end
end
