module Restmachine
  module Session
    class SessionEndpoint < Webmachine::Resource
      include Endpoint
      def self.create authenticator, controller: nil, **opts
        Class.new(self) do
          include Controller
          include controller if controller
          def include
            super()
          end
          define_method :authenticator do
            authenticator
          end
        end
      end
      #Performs login
      def handle_request
        credentials = login
        if credentials
          generate_xsrf_token
          opts = {xsrf: xsrf_token, exp: xsrf_expiration, ttl: xsrf_ttl}
          authenticator.create_session credentials, response, opts
          @post_result = credentials
          generate_post_response
          return true
        else
          generate_post_response
          return 403
        end
      end
      #Performs logout
      def delete_resource
        logout
        authenticator.destroy_session response
        generate_xsrf_token
        true
      end
      def resource_exists?
        true
      end
      def verify_xsrf
        false
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
