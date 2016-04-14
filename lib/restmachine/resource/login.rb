require 'securerandom'
require 'json'
module Restmachine
  module Resource
    class Login
      def self.create authenticator: Restmachine::Authenticator::JWT, &block
        Class.new(PostAction.new) do
          @authenticator = authenticator
          @authenticate = block
          
          def self.authenticator
            @authenticator
          end
          def self.authenticate
            @authenticate
          end
          def authenticate
            self.class.authenticate
          end
          def authenticator
            self.class.authenticator
          end
          def process_post
            instance_exec &authenticate, &(authenticator.method(:login))
          end
        end
      end
    end
  end
end
