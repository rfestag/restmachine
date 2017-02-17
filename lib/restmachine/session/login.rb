module Restmachine
  module Session
    class Login < SessionEndpoint
      def allowed_methods
        %w(OPTIONS GET POST)
      end
    end
  end
end
