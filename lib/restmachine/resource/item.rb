require 'json'
module Restmachine
  module Resource
    module Item 
      def create model, controller: Controller, authenticator: nil
        Class.new(Webmachine::Resource) do
          include Endpoint
          include Item
          include controller
          include authenticator if authenticator
          @model = model
          def self.model
            @model
          end
          def model
            self.class.model
          end
        end
      end
      module_function :create

      def allowed_methods
        %w(GET PUT DELETE)
      end
      def resource
        @resource ||= find
      end
      def handle_request
        update if request.put?
      end
      def to_json
        resource.to_json
      end
      def resource_exists?
        resource
      end
      def delete_resource
        delete
      end
    end
  end
end
