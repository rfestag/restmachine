require 'json'
module Restmachine
  module Resource
    class Action < Model
      def allowed_methods
        %w(OPTIONS POST)
      end
      def forbidden?
        if resource 
          check = (action+'?').to_sym
          begin
            authorize(resource, check)
          rescue NoMethodError => e
            handle_unauthorized(Pundit::NotDefinedError.new("unable to find authorization for #{action}"))
            return true
          end
        end
        #The 'authorize' methods don't return anything. If we get here,
        #then no excpetions or explicit returns occurred, so the user is authorized for the action
        return false
      #Occurs when user access to perform specified action on resource explicitly fails
      rescue Pundit::NotAuthorizedError => e
        handle_unauthorized(e)
        true
      #Occurs when no policy/check is defined the the specified action on resource
      rescue Pundit::NotDefinedError => e
        handle_unauthorized(e)
        true
      end
      def resource
        #We do it this way for cases where a resource
        #doesn't exist. We don't want to look up more than once
        return @resource if @lookup_done
        @resource = show
        return false unless @resource
        @action = item_methods.map{|m| m.to_s}.include?(action) ? action.to_sym : nil
        return false unless @action
        @lookup_done = true
        @resource
      end
      def handle_request
        attributes = validated_attributes(params, resource, @action)
        if attributes.respond_to? :success?
          if attributes.success?
            attributes == nil ? send(@action) : send(@action, attributes.to_h)
            generate_post_response
            true
          else
            errors << attributes.messages
            generate_post_response
            422
          end
        else
          attributes == nil ? send(@action) : send(@action, attributes.to_h)
          generate_post_response
          200
        end
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
