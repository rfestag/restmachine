require 'spec_helper'
require './spec/restmachine/applications/secure'

describe Restmachine::Authenticator do
  describe 'JWT Tokens' do
    it 'should support HMAC' do
      credentials = {data: 'test'}
      authenticator = Restmachine::Authenticator::JWT.new algorithm: 'HS256'
      token = authenticator.encode_token credentials
      decoded, = authenticator.decode_token token
      expect(decoded['data']).to eq('test')
    end
    it 'should support RSA' do
      credentials = {data: 'test'}
      authenticator = Restmachine::Authenticator::JWT.new algorithm: 'RS256'
      token = authenticator.encode_token credentials
      decoded, = authenticator.decode_token token
      expect(decoded['data']).to eq('test')
    end
    it 'should support ECDSA' do
      credentials = {data: 'test'}
      authenticator = Restmachine::Authenticator::JWT.new algorithm: 'ES256'
      token = authenticator.encode_token credentials
      decoded, = authenticator.decode_token token
      expect(decoded['data']).to eq('test')
    end
  end
end
