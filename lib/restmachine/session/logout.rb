module Restmachine
  module Session
    class Logout < SessionEndpoint
      def allowed_methods
        %w(DELETE)
      end
    end
  end
end
