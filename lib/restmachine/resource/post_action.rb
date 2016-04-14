[[module Restmachine
  module Resource
    class PostAction 
      def self.create controller, base: Endpoint, **opts
        Class.new(base) do
          @controller = controller
          def self.controller
            @controller
          end
          def controller
            self.class.controller
          end
          def allowed_methods
            %w(POST)
          end
          def resource
            @resource ||= instance_exec &(controller.find)
          end
          def to_json
            resource.to_json
          end
          def resource_exists?
            resource
          end
          def delete_resource
            instance_exec &(controller.delete)
          end
        end
      end
    end
  end
end
