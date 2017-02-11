module Restmachine
  class ApplicationPolicy
    attr_reader :user, :resource
    def initialize user, resource
      @user = user
      @resource = resource
    end
    def create?
      true
    end
    def update?
      true
    end
    def delete?
      true
    end
    def show?
      true
    end
    def visible_attributes
      #By default, don't return _id
      @visible_attributes ||= model.fields.keys - ['_id']
    end
    def model
      @resource.is_a?(Class) ? @resource : @resource.class
    end
    class Scope
      attr_reader :user, :scope
      def initialize user, scope
        @user = user
        @scope = scope
      end
      def resolve
        scope.all
      end
    end
  end
end
