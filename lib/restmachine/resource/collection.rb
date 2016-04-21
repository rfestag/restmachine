require 'securerandom'
require 'bson'
require 'json'
module Restmachine
  module Resource
    module Collection
      def create *args
        klass = Class.new(Default.create(*args)) do
          def allowed_methods
            %w(GET POST)
          end
          def create_path
            "#{path}/#{next_id}"
          end
          def post_is_create?
            true
          end
          def handle_request
            if post_is_create? and request.post?
              authorize model, :create?
              create @next_id
            end
          rescue Pundit::NotAuthorizedError => e
            unauthorized e.message
          end
          def to_json
            list.to_json
          end
          def to_html
            @resources = policy_scope(list)
            @errors = errors
            render template: "#{model.name.pluralize.underscore}"
          end
          def next_id
            #@next_id = SecureRandom.hex 16
            @next_id = BSON::ObjectId.new
          end
        end
        klass
      end
      module_function :create
    end
  end
end
