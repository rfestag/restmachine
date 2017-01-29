require 'seconds'
require 'jwt'
module Restmachine
  module Authenticator
    class JWTCookie < JWT
      DEFAULT_TTL = 6.hours
      def create_session payload, response, opts={}
        opts[:ttl] ||= DEFAULT_TTL
        opts[:xsrf] ||= SecureRandom.hex 32
        expires = Time.now + opts[:ttl]
        payload[:exp] = expires
        payload[:xsrfToken] ||= opts[:xsrf]
        token = super payload, response, opts
        response.set_cookie 'USER-TOKEN', token, secure: true, httponly: true, expires: expires
        response.set_cookie 'XSRF-TOKEN', opts[:xsrf], secure: true, expires: expires
        token
      end
      def destroy_session response
        now = Time.now
        response.set_cookie 'USER-TOKEN', '', secure: true, httponly: true, expires: now
        response.set_cookie 'XSRF-TOKEN', '', secure: true, expires: now
      end
      def get_token header, request
        request.cookies['USER-TOKEN']
      end
    end
  end
end
