require 'webmachine'
module Restmachine
  module Resource
    class Model < Webmachine::Resource
      include Endpoint
      
      def self.create model, path: nil, 
                             controller: nil, 
                             authenticator: nil
        Class.new(self) do
          include (controller || Controller)
          include authenticator if authenticator
          define_method :path do
            path
          end
          define_method :model do
            model
          end
        end
      end
    end
  end
end
