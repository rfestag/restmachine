require 'bson'
require 'json'
module Restmachine
  module Resource
    class Collection < Model
      def allowed_methods
        %w(OPTIONS GET POST)
      end
      def create_path
        @create_path ||= "#{path}/#{next_id}"
      end
      def forbidden?
        #Only need to do XSRF detection if this is a create. Otherwise it is a list via GET
        if post_is_create? and request.post?
          authorize(model, :create?)
        end
        #If we get here without throwing an exception, we can access the resource
        false
      rescue Restmachine::XSRFValidityError, Pundit::NotAuthorizedError => e
        handle_unauthorized(e)
        true
      end
      def post_is_create?
        true
      end
      def handle_request
        if post_is_create? and request.post?
          attributes = validated_attributes(params, model, :create)
          if attributes.respond_to? :messages 
            if attributes.messages.length == 0
              resource = create attributes.to_h
              @create_path = "#{path}/#{resource.uri}"
              response.headers['Location'] = @create_path
            else
              response.headers.delete 'Location'
              errors << attributes.messages
              generate_post_response
              422
            end
          else
            puts "No validations provided, using raw params hash"
            resource = create params
            @create_path = "#{path}/#{resource.uri}"
            response.headers['Location'] = @create_path
          end
        end
      end
      def to_json
        if errors.empty?
          visible = visible_attributes(model, :show)
          resources = policy_scope(model)
          visible ? resources.to_json(only: visible) : resources.to_json
        else
          {errors: errors}.to_json
        end
      end
      def to_html
        @resources = policy_scope(list)
        @errors = errors
        render template: "#{model.name.pluralize.underscore}"
      end
      def next_id
        @next_id = BSON::ObjectId.new
      end
    end
  end
end
