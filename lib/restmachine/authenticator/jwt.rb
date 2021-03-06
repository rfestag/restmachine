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
          @algorithm = algorithm
          return
        else
          @validate = true
          @algorithm = algorithm
        end

        case algorithm
        when /RS(\d{3})/
          case @secret
          when String
            #TODO: parse contents of @secret (file)
            raise "Not implemented yet."
          when nil
            @secret = OpenSSL::PKey::RSA.generate 2048
            @issuer = SecureRandom.hex 32
          end
          raise InvalidCredentialError.new "Secret was not a valid type for #{algorithm}: #{@secret.class}" unless @secret.is_a? OpenSSL::PKey::RSA
          @public = @secret.public_key
        when /ES(\d{3})/
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
        when /HS(\d{3})/
          secret ||= SecureRandom.hex 32
          @secret = secret
          raise InvalidCredentialError.new "Secret was not a valid type for #{algorithm}: #{@secret.class}" unless @secret.is_a? String
          @public = secret
          @issuer = SecureRandom.hex 32
        else
          raise InvalidAlgorithmError.new 'Algorithm not recognized'
        end
        @issuers[@issuer] = @public
        @block = Proc.new if block_given?
      end
      def encode_token credentials
        credentials[:exp] = credentials[:exp].to_i if credentials[:exp]
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
          rescue ::JWT::ExpiredSignature, ::JWT::VerificationError => e
            puts "#{e.class}: #{e.message}"
            return nil
          end 
        else
          return nil 
        end
      end
      def validate_session header, request
        credentials = nil
        token = get_token header, request
        #If there is a token, decode it
        if token
          issuer = (@issuers.length == 1) ? @issuer : JSON.parse(Base64.decode64(token.split('.').first))['iss']
          credentials, jwt_header = decode_token token, issuer: issuer
        end
        #Pass the successfully decoded credentials to the block (or nil if the credentials are invalid/nonexistant)
        @block.nil? ? credentials : @block.call(credentials)
      end
    end
  end
end
