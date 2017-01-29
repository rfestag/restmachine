module Restmachine
  module Resource
    module Controller
      def list
        policy_scope(model)
      end
      def create id
        obj = model.new(params)
        obj.id = id
        if obj.respond_to? :valid? and obj.valid?
          obj.save!
        else
          errors = errors << obj.errors.full_messages
        end
      end
      def show
        model.find(id)
      end
      def update
        obj = resource
        if obj.respond_to? :valid? and obj.valid?
          resource.update_attributes!(params)
        else
          errors = errors << obj.errors.full_messages
        end
      end
      def delete
        resource.destroy
      end
    end
  end
end
