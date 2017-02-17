require 'json'
module Restmachine
  module Resource
    class Item < Model
      def allowed_methods
        %w(GET PUT DELETE)
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
            authorize(resource, :show?)
          elsif request.put?
            @action = :update
            authorize(resource, :update?)
          elsif request.delete?
            authorize(resource, :delete?)
          end
        end
        #If we get here without throwing an exception, we can access the resource
        false
      rescue Pundit::NotAuthorizedError => e
        handle_unauthorized(e)
        true
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
        attributes = validated_attributes(params, resource, @action)
        if attributes.respond_to? :messages
          if attributes.messages.length == 0
            update attributes.to_h
          else
            errors << attributes.messages
            generate_post_response
            422
          end
        else
          resource = update params
        end
      end
      def handle_delete
        delete
      end
      def to_json
        if errors.empty?
          visible = visible_attributes(resource, :show)
          visible ? resource.to_json(only: visible) : resource.to_json
        else
          {errors: errors}.to_json
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
    end
  end
end
