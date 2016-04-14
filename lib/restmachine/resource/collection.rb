require 'securerandom'
require 'json'
module Restmachine
  module Resource
    module Collection
      def create model, controller: Controller, authenticator: nil
        Class.new(Webmachine::Resource) do
          include Endpoint
          include Collection
          include controller
          include authenticator if authenticator
          @model = model
          def self.model
            @model
          end
          def model
            self.class.model
          end
        end
      end
      module_function :create

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
        create if post_is_create? and request.post?
      end
      def to_json
        list.to_json
      end
      def next_id
        @next_id = SecureRandom.hex 16
      end
    end
  end
end
