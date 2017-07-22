require 'spec_helper'
require './spec/restmachine/applications/secure'

describe Restmachine::Session do
  include Webmachine::Test

  let(:app) {SecureApp}

  before do
    Order.delete_all
    User.delete_all
    User.create username: 'User1', admin: false
    User.create username: 'Admin1', admin: true
  end

  describe 'Session management' do
    it 'should return 403 if login can\'t find a user' do
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'
      body({username: 'User2'}.to_json)
      post '/login'
      expect(response.code).to eq(403)
    end
    it 'should return the logged in user if they are found' do
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'
      body({username: 'User1'}.to_json)
      post '/login'
      expect(response.code).to eq(200)
      expect(response.headers['Content-Type']).to eq('application/json')
      expect(JSON.parse(response.body)['username']).to eq("User1")
    end
    it 'should allow authenticated users to create orders' do
      user = User.find_by username: 'User1'
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'
      body({username: 'User1'}.to_json)
      post '/login'
      protect_from_forgery
      body({items: ['Item1', 'Item2']}.to_json)
      post '/orders'
      expect(response.code).to eq(201)
      expect(response.headers['Content-Type']).to eq('application/json')
      expect(Order.first.user_id).to eq(user.id)
    end
    it 'should not allow unauthenticated users to create orders' do
      body({items: ['Item1', 'Item2']}.to_json)
      post '/orders'
      expect(response.code).to eq(403)
    end
    it 'should successfully log out' do
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'
      body({username: 'User1'}.to_json)
      post '/login'
      expect(response.code).to eq(200)
      delete '/logout'
      expect(response.code).to eq(204)
      body({items: ['Item1', 'Item2']}.to_json)
      post '/orders'
      expect(response.code).to eq(403)
    end
  end
end
