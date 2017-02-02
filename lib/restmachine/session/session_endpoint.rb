module Restmachine
  module Session
    class SessionEndpoint < Webmachine::Resource
      include Endpoint

      def self.create authenticator, controller: nil, **opts
        Class.new(self) do
          include (controller || Controller)
          def include
            super()
          end
          define_method :authenticator do
            authenticator
          end
        end
      end
      def allowed_methods
        %w(POST)
      end
      def process_post
        @post_result = handle_request
        if @post_result === Fixnum
          return @post_result
        elsif !request.redirect
          generate_post_response
          #encode_body if @post_result
        end
        true
      end
      def resource_exists?
        true
      end
      def to_json
        unless @post_result.nil?
          response.headers['Content-Type'] = 'application/json'
          response.body = @post_result.to_json
        end
      end
      def to_html
        render
      end
    end
  end
end
