require 'json'
module Restmachine
  module Resource
    class Item < Model
      def allowed_methods
        %w(GET PUT POST DELETE)
      end
      def allow_missing_put?
        true
      end
      def is_conflict?
        if request.put? and resource.nil?
          !allow_missing_put?
        else
          false
        end
      end
      def forbidden?
        if resource
          if request.get?
            authorize resource, :show?
          elsif request.put?
            authorize resource, :update?
            @action = :update
          elsif request.delete?
            authorize resource, :delete?
          elsif request.post?
            authorize resource, "#{action}?".to_sym
          end
        elsif allow_missing_put? and request.put?
          authorize model, :create?
          @action = :create
        end
        false
      rescue Pundit::NotAuthorizedError => e
        puts e.inspect
        unauthorized(e)
      end
      def resource
        #We do it this way for cases where a resource
        #doesn't exist. We don't want to look up more than once
        return @resource if @lookup_done
        @resource = show
        @lookup_done = true
        @resource
      end
      def handle_request
        case @action
        when :update
          update
        when :create
          create
          201
        end
      end
      def process_post
        result = resource.send action.to_sym
        #TODO: format body as requested
        #TODO: set headers
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
        delete
        true
      end
    end
  end
end
