require 'jwt'
module Restmachine
  module Authenticator
    class JwT
      def initialize secret: , algorithm:
        @secret = secret
        @algorithm = algorithm
        case @secret.class
          when OpenSSL::PKey::EC
            @public = OpenSSL::PKey::EC.new @secret
            @public.private_key = nil
          when OpenSSL::PKey::RSA
            @public = @secret.public_key
        end
      end
      def login
        payload = yield params
        if payload
          token = JWT.encode payload, secret, true, algorithm: @algorithm
          response.headers['Authenticate'] = "Bearer #{token}"
          true
        else
          401
        end
      end
      def authenticate
      end
    end
  end
end
