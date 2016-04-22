require 'json'
module Restmachine
  module Resource
    class Item < Model
      def allowed_methods
        %w(GET PUT DELETE)
      end
      def resource
        #We do it this way for cases where a resource
        #doesn't exist, or we aren't allowed to access
        #it.
        return @resource if @lookup_done
        @resource = find
        authorize @resource, :show? if @resource
      rescue Pundit::NotAuthorizedError => e
        @resource = nil
      ensure
        @lookup_done = true
      end
      def handle_request
        if request.put?
          if resource_exists?
            authorize resource, :update?
            update
          else
            authorize model, :create?
            create
            201
          end
        end
      rescue Pundit::NotAuthorizedError => e
        unauthorized e.message
      end
      def to_json
        if errors.empty?
          resource.to_json
        else
          response.body = {errors: errors}.to_json
        end
      end
      def to_html
        @resource = resource
        @errors = errors
        render
      end
      def resource_exists?
        resource
      end
      def delete_resource
        authorize resource, :delete?
        delete
        true
      rescue Pundit::NotAuthorizedError => e
        unauthorized e.message
      end
    end
  end
end
