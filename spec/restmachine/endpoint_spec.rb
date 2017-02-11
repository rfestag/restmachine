require 'spec_helper'
require './spec/restmachine/applications/cors'

describe Restmachine::Endpoint do
  include Webmachine::Test

  let(:app) {CORSApp}

  before do
    Person.delete_all
  end

  describe 'XSRF (CSRF) prevention' do
    #XSRF protection is done via double-submit. Any protected request must submit
    #both an XSRF-TOKEN cookie and either X-XSRF-TOKEN header of authentication_token parameter
    it 'should fail if the origin is not explicitly allowed' do
      header 'Origin', 'badguy.org:80'
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'
      body({name: 'name', age: 21}.to_json)
      post '/people'
      expect(response.code).to eq(403)
    end
    it 'should fail if no tokens are sent via cookie, headers, or parameters' do
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'
      body({name: 'name', age: 21}.to_json)
      post '/people'
      expect(response.code).to eq(403)
    end
    it 'should fail unauthorized when there is no double submit with the cookie' do
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'
      cookie 'XSRF-TOKEN', 'FAKE_XSRF_TOKEN'
      body({name: 'name', age: 21}.to_json)
      post '/people'
      expect(response.code).to eq(403)
    end
    it 'should accept authenticity_token parameter' do
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'
      cookie 'XSRF-TOKEN', 'FAKE_XSRF_TOKEN'
      body({name: 'name', age: 21, authenticity_token: 'FAKE_XSRF_TOKEN'}.to_json)
      post '/people'
      expect(response.code).to eq(201)
      location = response.headers['Location']
      id = location.split('/').last
      expect(Person.find(id).id.to_s).to eq(id)
    end
    it 'should accept X-XSRF-TOKEN header for double submit' do
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'
      header 'X-XSRF-TOKEN', 'FAKE_XSRF_TOKEN'
      cookie 'XSRF-TOKEN', 'FAKE_XSRF_TOKEN'
      body({name: 'name', age: 21}.to_json)
      post '/people'
      expect(response.code).to eq(201)
      location = response.headers['Location']
      id = location.split('/').last
      expect(Person.find(id).id.to_s).to eq(id)
    end
  end
  describe 'CORS support' do
    it 'should accept explicitly allowed origins' do
      header 'Origin', 'www.valid.com:80'
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'
      protect_from_forgery
      body({name: 'name', age: 21}.to_json)
      post '/people'
      expect(response.code).to eq(201)
      expect(response.headers['Access-Control-Allow-Origin']).to eq('www.valid.com:80')
      expect(response.headers['Access-Control-Allow-Methods']).to eq('GET,POST')
      expect(response.headers['Access-Control-Allow-Headers']).to eq('DNT,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Content-Range,Range')
      expect(response.headers['Access-Control-Expose-Headers']).to eq('DNT,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Content-Range,Range')
    end
  end
  describe 'Format management' do
    it 'returns an empty json array' do
      header 'Accept', 'application/json'
      get '/people.json'
      expect(response.code).to eq(200)
      expect(response.headers['Content-Type']).to eq('application/json')
      expect(response.body).to eq('[]')
    end
    it 'returns HTML' do
      get '/people.html'
      expect(response.code).to eq(200)
      expect(response.headers['Content-Type']).to eq('text/html')
    end
  end
end
