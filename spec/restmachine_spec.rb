require 'webmachine/test'
require 'spec_helper'
require 'mongoid'

Mongoid.load!("mongoid.yml", :production)

class Order
  include Mongoid::Document
end
class OrdersController < Restmachine::Controller
end

MyApp = Webmachine::Application.new do |app|
  key = OpenSSL::PKey::EC.new 'prime256v1'
  key.generate_key

  app.routes do
    add "/login", Restmachine::Resource::Login.create secret: key, algorithm: 'HS256'
    add "/orders/:id", Restmachine::Resource::Item.create(OrdersController.new)
    add "/orders", Restmachine::Resource::Collection.create(OrdersController.new)
  end
end

describe Restmachine do
  include Webmachine::Test

  let(:app) {MyApp}

  it 'has a version number' do
    expect(Restmachine::VERSION).not_to be nil
  end

  describe 'GET /orders' do
    it 'succeeds' do
      get '/orders'
      expect(response.code).to be(200)
    end
    it 'replies with empty JSON array' do
      get '/orders'
      expect(response.body).to eq("[]")
    end
    it 'replies with content-type of application/json' do
      get '/orders'
      expect(response.headers['Content-Type']).to eq('application/json')
    end
  end
end
