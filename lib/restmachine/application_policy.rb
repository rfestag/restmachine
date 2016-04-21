module Restmachine
  class ApplicationPolicy
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
