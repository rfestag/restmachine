require 'mongoid'
require 'webmachine/test'
require 'spec_helper'

Mongoid.load!("mongoid.yml", :production)

Webmachine::ActionView.configure do |config|
  config.view_paths = ['spec/views/']
  config.handlers = [:erb, :haml, :builder]
end
class OrderPolicy < Restmachine::ApplicationPolicy; end
class Order
  include Mongoid::Document
  field :name
end
class Authenticator
  def login
    puts "Login called"
    {name: 'Guest'}
  end
end

MyApp = Webmachine::Application.new do |app|
  key = OpenSSL::PKey::EC.new 'prime256v1'
  key.generate_key

  app.routes do
    login Restmachine::Authenticator::JWTCookie, controller: Authenticator
    resource Order
  end
end

describe Restmachine do
  include Webmachine::Test

  let(:app) {MyApp}

  before do
    Order.delete_all
  end

  it 'has a version number' do
    expect(Restmachine::VERSION).not_to be nil
  end

  describe 'Log in' do
    it 'should redirect to application root' do
      header 'Accept', 'application/json'
      post '/login'
      expect(response.code).to eq(303)
      expect(response.headers['Location']).to eq('/')
      #expect(response.headers['Content-Type']).to eq('application/json')
      #expect(response.body).to eq('{name: Guest}')
    end
  end
  describe 'GET /orders' do
    it 'returns an empty json array' do
      header 'Accept', 'application/json'
      get '/orders.json'
      expect(response.code).to eq(200)
      expect(response.headers['Content-Type']).to eq('application/json')
      expect(response.body).to eq('[]')
    end
    it 'returns HTML' do
      get '/orders.html'
      expect(response.code).to eq(200)
      expect(response.headers['Content-Type']).to eq('text/html')
    end
  end
  describe 'GET /orders/1' do
    it 'returns 404 because there is no resource' do
      header 'Accept', 'application/json'
      get '/orders/1.json'
      expect(response.code).to eq(404)
    end
  end
  describe 'Object Lifecycle for /orders' do
    it 'creates an order object, updates it, and deletes it' do
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'
      body({name: 'name'}.to_json)
      post '/orders'
      expect(response.code).to eq(201)
      location = response.headers['Location']
      get location
      expect(response.code).to eq(200)
      expect(response.headers['Content-Type']).to eq('application/json')
      obj = JSON.parse(response.body)
      id = obj['_id']['$oid']
      expect(obj['name']).to eq('name')
      obj['name'] = "newname"
      body obj.to_json
      put "/orders/#{id}"
      expect(response.code).to eq(204)
      expect(response.headers['Content-Type']).to eq('application/json')
      get "/orders/#{id}"
      expect(response.code).to eq(200)
      expect(response.headers['Content-Type']).to eq('application/json')
      obj = JSON.parse(response.body)
      expect(obj['name']).to eq('newname')
      delete "/orders/#{id}"
      expect(response.code).to eq(204)
      get "/orders/#{id}"
      expect(response.code).to eq(404)
    end
  end
end
