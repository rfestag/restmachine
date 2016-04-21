require 'pundit'
module Restmachine
  module Resource
    module Default
      def create model, path: nil, controller: nil, authenticator: nil
        klass = Class.new(Webmachine::Resource) do
          include Pundit
          include Webmachine::ActionView::Resource
          include Webmachine::Resource::Authentication
          include Endpoint
          include (controller || Controller)
          include authenticator if authenticator
          def unauthorized msg
            #TODO: Allow user to set body
            403
          end
        end
        klass.send(:define_method, :path) do
          path
        end
        klass.send(:define_method, :model) do 
          model
        end
        klass
      end
      module_function :create
    end
  end
end
