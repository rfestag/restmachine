module Restmachine
  module Resource
    module PostAction 
      def create model, method, *args
        Class.new(Default.create(model, *args) do
          def allowed_methods
            %w(POST)
          end
          def process_post
            controller.send method
          end
        end 
      end
    end
  end
end
