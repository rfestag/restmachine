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
    it 'should support no validation' do
      credentials = {data: 'test'}
      authenticator = Restmachine::Authenticator::JWT.new algorithm: 'none'
      token = authenticator.encode_token credentials
      puts token.inspect
      decoded, = authenticator.decode_token token
      expect(decoded['data']).to eq('test')
    end
    it 'should fail if invalid algorithm used' do
      credentials = {data: 'test'}
      expect{Restmachine::Authenticator::JWT.new algorithm: 'bob'}.to raise_error(Restmachine::Authenticator::InvalidAlgorithmError)
    end
  end
end
