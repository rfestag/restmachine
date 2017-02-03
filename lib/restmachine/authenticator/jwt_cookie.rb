require 'seconds'
require 'jwt'
module Restmachine
  module Authenticator
    class JWTCookie < JWT
      DEFAULT_TTL = 6.hours
      def create_session credentials, response, opts={}
        payload = credentials.dup
        payload[:exp] = Time.now + opts[:ttl]
        payload[:xsrfToken] = opts[:xsrf]
        token = encode_token(payload)
        response.set_cookie 'USER-TOKEN', token, secure: true, httponly: true, expires: payload[:exp]
        token
      end
      def destroy_session response
        now = Time.now
        response.set_cookie 'USER-TOKEN', '', secure: true, httponly: true, expires: now
      end
      def get_token header, request
        request.cookies['USER-TOKEN']
      end
    end
  end
end
