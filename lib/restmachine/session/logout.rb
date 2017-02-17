module Restmachine
  module Session
    class Logout < SessionEndpoint
      def allowed_methods
        %w(OPTIONS DELETE)
      end
    end
  end
end
