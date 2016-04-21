require 'jwt'
module Webmachine
  class Resource
    # Helper methods that can be included in your
    # {Webmachine::Resource} to assist in performing HTTP
    # Authentication.
    module Authentication
      # Pattern for matching Authorization headers that use the Bearer
      # token scheme
      TOKEN_HEADER = /^Bearer (.*)$/i.freeze

      # A simple implementation of bearer token auth. Call this from the
      # {Webmachine::Resource::Callbacks#is_authorized?} callback,
      # giving it a block which will be yielded the token and
      # return true or false.
      # @param [String] header the value of the Authentication request
      #   header, passed to the {Callbacks#is_authorized?} callback.
      # @param [String] realm the "realm", or description of the
      #   resource that requires authentication
      # @return [true, String] true if the client is authorized, or
      #   the appropriate WWW-Authenticate header
      # @yield [token] a block that will verify the client-provided token
      # @yieldparam [String] token the passed token
      # @yieldreturn [true,false] whether the token is valid
      def token_auth(header, realm='Webmachine')
        token = TOKEN_HEADER.match header
        if token and yield token
          true
        else
          %Q[Bearer realm="#{realm}"]
        end
      end
      def jwt_auth(header, secret, alg, realm='Webmachine')
        token_auth(header, realm) do |token|
          begin 
            payload, headers = JWT.decode token, secret, true, algorithm: alg
            #TODO:Verify expiration
            yield payload, headers
          rescue JWT::VerificationError => e
            %Q[Bearer realm=#{realm}\nerror=invalid_token\nerror_description="Signature verification failed]
          end
        end
      end
      def jwt_login realm='Webmachine'
        payload = yield params
        if payload
          token = JWT.encode payload, secret, true, algorithm: @algorithm
          response.headers['Authenticate'] = "Bearer #{token}"
          true
        else
          response.headers['WWW-Authenticate'] = INVALID_TOKEN
          401
        end
      end
    end
  end
end
