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
      def unauthorized?
        if post_is_create? and request.post?
          authorize(model, :create?)
        end
        #If we get here without throwing an exception, we can access the resource
        false
      end
      def post_is_create?
        true
      end
      def handle_request
        if post_is_create? and request.post?
          attributes = validated_attributes(params, model, :create)
          if attributes.success? || attributes.nil?
            resource = create(attributes ? attributes.to_h : nil)
            @create_path = "#{path}/#{resource.uri}"
            response.headers['Location'] = @create_path
          else
            response.headers.delete 'Location'
            errors << attributes.messages
            generate_post_response
            422
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
        if errors.empty?
          render template: "#{pluralized_name}/index.html"
        else
          response.headers['Location'] = request.headers['Referrer']
          nil
        end
      end
      def next_id
        @next_id = BSON::ObjectId.new
      end
    end
  end
end
