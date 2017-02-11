module Restmachine
  module Session
    class Login < SessionEndpoint
      def allowed_methods
        %w(GET POST)
      end
    end
  end
end
