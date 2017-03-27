require 'json'
module Restmachine
  module Resource
    class Item < Model
      def allowed_methods
        %w(OPTIONS GET PUT POST DELETE)
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
            @action = :show
            authorize(resource, :show?)
          elsif request.put?
            @action = :update
            authorize(resource, :update?)
          elsif request.post?
            action = request.path_info[:id]
            check = (action+'?').to_sym
            @action = action.to_sym
            begin
              authorize(model, check)
            rescue NoMethodError => e
              handle_unauthorized(Pundit::NotDefinedError.new("unable to find authorization for #{action}"))
              return true
            end
          elsif request.delete?
            @action = :delete
            authorize(resource, :delete?)
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
        if collection_methods.map{|m| m.to_s}.include? id
          @resource = model
        else
          @resource = show
        end
        @lookup_done = true
        @resource
      end
      def handle_request
        attributes = validated_attributes(params, resource, @action)
        if attributes.nil? || attributes.success?
          if request.post?
            attributes == nil ? self.class.send(@action) : self.class.send(@action, attributes.to_h)
            generate_post_response
            true
          else
            update attributes.to_h
          end
        else
          errors << attributes.messages
          generate_post_response
          422
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
        if errors
          response.headers['Location'] = request.headers['Referrer']
        else
          render template: "#{pluralized_name}/#{@action}.html"
        end
      end
      def resource_exists?
        resource
      end
    end
  end
end
