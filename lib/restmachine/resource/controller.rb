module Restmachine
  module Resource
    module Controller
      module ClassMethods
      end
      def list
        model.all
      end
      def create attributes
        model.create! attributes
      end
      def show
        model.find(id)
      end
      def update attributes
        resource.update_attributes!(attributes.to_h)
      end
      def delete
        resource.destroy
        204
      end
      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
