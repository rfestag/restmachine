module Restmachine
  module OAuth
    class Callback < Webmachine::Resource
      include Endpoint
      def self.create authenticator, provider, controller, app_id: nil, secret: nil, redirect_to: '/', **opts
        Class.new(self) do
          include provider
          include controller if controller
          def include
            super()
          end
          define_method :authenticator do
            authenticator
          end
          define_method :app_id do
            app_id
          end
          define_method :secret do
            secret
          end
        end
      end
      def allowed_methods
        %w(OPTIONS GET)
      end
      def content_types_provided
        [['*/*', :handle_oauth]]
      end
      def code
        request.query['code']
      end
      def client
        @client ||= OAuth2::Client.new(app_id, secret, site: site, token_url: token_url)
      end
      def callback_url
        uri = request.uri
        @callback_url ||= "#{uri.scheme}://#{uri.host}:#{uri.port}#{uri.path}"
      end
      def token
        @token ||= client.auth_code.get_token(code, redirect_uri: callback_url)
      end
      def redirect_to
        nil
      end
      def handle_oauth
        credentials = login get_user_info
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

        if redirect_to
          response.headers['Location'] = redirect_to
          200
        else
          resp.body
        end
      end
    end
  end
end
