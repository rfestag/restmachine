require 'jwt'
module Restmachine
  module Authenticator
    class InvalidAlgorithmError < StandardError; end
    class InvalidCredentialError < StandardError; end
    class JWT
      def initialize algorithm: 'none', secret: nil
        if secret.nil? and algorithm == 'none'
          @secret = secret
          @arguments = (algorithm == 'none') ? [false] :
                                               [true, {algorithm: algorithm}] 
          return
        elsif @secret.is_a? String
          case algorithm
          when /RS\d{3}/
            #TODO: parse contents of @secret (file)
          when /ED\d{3}/
            #TODO: parse contents of @secret (file)
          when /HS\d{3}/
            @secret = secret
            @public = secret
            return
          else
            raise InvalidAlgorithmError.new 'Algorithm not recognized'
          end
        end

        case @secret.class
        when OpenSSL::PKey::EC
          @public = OpenSSL::PKey::EC.new @secret
          @public.private_key = nil
        when OpenSSL::PKey::RSA
          @public = @secret.public_key
        else
          raise InvalidCredentialError.new "Secret was not a valid type"
        end
      end
      def login params
        payload = yield params
        if payload
          JWT.encode payload, @secret, *@arguments
        else
          nil
        end
      end
      def authenticate token
        if token
          begin
            yield JWT.decode t, @secret, *@arguments
          rescue JWT::VerificationError => e
            false
          end
        else
          false
        end
      end
    end
  end
end
