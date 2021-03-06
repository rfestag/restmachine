require 'json'
module Restmachine
  module Resource
    class Action < Model
      def allowed_methods
        %w(OPTIONS POST)
      end
      def unauthorized?
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
        if attributes.success?
          attributes == nil ? send(@action) : send(@action, attributes.to_h)
          generate_post_response
          true
        else
          errors << attributes.messages
          generate_post_response
          422
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
        if errors.empty?
          render template: "#{pluralized_name}/#{@action}.html"
        else
          response.headers['Location'] = request.headers['Referrer'] if @errors
        end
      end
      def resource_exists?
        resource
      end
    end
  end
end
