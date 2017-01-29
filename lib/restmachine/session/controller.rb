module Restmachine
  module Session
    module Controller
      def login
        puts "Warning: You are using the default login controller. You should override the login method"
        response.do_redirect '/'
        nil
      end
      def logout
        response.do_redirect '/'
      end
    end
  end
end
