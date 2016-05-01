require 'securerandom'
require 'json'
module Restmachine
  module Resource
    class Login < Webmachine::Resource
      include Endpoint
      include PostAction

      def self.create authenticator
        define_method :authenticator do
          authenticator
        end
      end
      
      def login
        #Example - This should be overridden
        if params[:username] == 'admin' and
           params[:password] == 'admin'
        
        end

        #TODO: Handle login using authenticator
      end
    end
  end
end
