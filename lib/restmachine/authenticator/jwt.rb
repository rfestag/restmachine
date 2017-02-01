require 'base64'
require 'seconds'
require 'jwt'
module Restmachine
  module Authenticator
    class InvalidAlgorithmError < StandardError; end
    class InvalidCredentialError < StandardError; end

    class JWT
      TOKEN_HEADER = /^Bearer (.*)$/i.freeze
      attr_reader :issuer

      def initialize algorithm: 'ES256', secret: nil, issuer: nil, trusted_issuers: {}
        @issuer = issuer
        @secret = secret
        @issuers = trusted_issuers
        if @secret.nil? and algorithm == 'none'
          @validate = false
          return
        else
          @validate = true
          @algorithm = algorithm
        end

        case algorithm
        when /RS\d{3}/
          case @secret
          when String
            #TODO: parse contents of @secret (file)
          when nil
            @secret = OpenSSL::PKey::RSA.generate 2048
            @issuer = SecureRandom.hex 32
          end
          raise InvalidCredentialError.new "Secret was not a valid type for #{algorithm}: #{@secret.class}" unless @secret.is_a? OpenSSL::PKey::RSA
          @public = @secret.public_key
        when /ES\d{3}/
          case @secret
          when String
            #TODO: parse contents of @secret (file)
          when nil
            @secret = OpenSSL::PKey::EC.new "prime#{$1}v1"
            @secret.generate_key
            @issuer = SecureRandom.hex 32
          end
          raise InvalidCredentialError.new "Secret was not a valid type for #{algorithm}: #{@secret.class}" unless @secret.is_a? OpenSSL::PKey::EC
          @public = OpenSSL::PKey::EC.new @secret
          @public.private_key = nil
        when /HS\d{3}/
          secret ||= SecureRandom.hex 32
          @secret = secret
          raise InvalidCredentialError.new "Secret was not a valid type for #{algorithm}: #{@secret.class}" unless @secret.is_a? String
          @public = secret
          @issuer = SecureRandom.hex 32
        else
          raise InvalidAlgorithmError.new 'Algorithm not recognized'
        end
        @issuers[@issuer] = @public
      end
      def encode_token credentials
        credentials[:iss] = @issuer
        ::JWT.encode(credentials, @secret, @algorithm)
      end
      def decode_token token, issuer: nil
        if token
          begin
            pub = (issuer)? @issuers[issuer] : @public
            if @algorithm == 'none'
              return ::JWT.decode(token, nil, false)
            else
              return (pub)? ::JWT.decode(token, pub, @validate, {algorithm: @algorithm}) : nil
            end
          rescue ::JWT::VerificationError => e
            return nil
          end 
        else
          return nil 
        end
      end
      def validate_session header, request
        token = get_token header, request
        if token
          issuer = (@issuers.length == 1) ? @issuer : JSON.parse(Base64.decode64(token.split('.').first))['iss']
          credentials = decode_token token, issuer: issuer
          if credentials
            yield credentials if block_given?
            return true
          else 
            return false
          end
        else
          return false
        end
      end
    end
  end
end
