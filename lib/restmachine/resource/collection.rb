require 'bson'
require 'json'
module Restmachine
  module Resource
    class Collection < Model
      def allowed_methods
        %w(GET POST)
      end
      def create_path
        "#{path}/#{next_id}"
      end
      def forbidden?
        if post_is_create? and request.post?
          authorize model, :create? and xsrf_valid?
        end
        false
      rescue Pundit::NotAuthorizedError => e
        unauthorized(e)
      end
      def post_is_create?
        true
      end
      def handle_request
        create @next_id if post_is_create? and request.post?
      end
      def to_json
        policy_scope(list).to_json
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
