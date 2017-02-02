require 'mongoid'
require 'webmachine/test'
require 'spec_helper'

Mongoid.load!("mongoid.yml", :production)

Webmachine::ActionView.configure do |config|
  config.view_paths = ['spec/views/']
  config.handlers = [:erb, :haml, :builder]
end
class PersonPolicy < Restmachine::ApplicationPolicy; 
  def schema
    Dry::Validation.Form do
      required(:name).filled(:str?)
      required(:age).filled(:int?, gt?: 18)
    end
  end
end
class Person
  include Mongoid::Document
  field :name, type: String
  field :age, type: Integer

  def uri
    id
  end
end
module LoginController
  def login
    {name: 'Guest'}
  end
end

MyApp = Webmachine::Application.new do |app|
  key = OpenSSL::PKey::EC.new 'prime256v1'
  key.generate_key
  authenticator = Restmachine::Authenticator::JWTCookie.new secret: key

  app.routes do
    login authenticator, controller: LoginController
    resource Person
  end
end

describe Restmachine do
  include Webmachine::Test

  let(:app) {MyApp}

  before do
    Person.delete_all
  end

  it 'has a version number' do
    expect(Restmachine::VERSION).not_to be nil
  end

  describe 'Log in' do
    it 'should provide json of user' do
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/x-www-form-url-encoded'
      post '/login', {valid_credentials: true}
      expect(response.code).to eq(200)
      expect(response.headers['Content-Type']).to eq('application/json')
      expect(response.body).to eq({name: "Guest"}.to_json)
    end
  end
  describe 'GET /people' do
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
  describe 'GET /people/1' do
    it 'returns 404 because there is no resource' do
      header 'Accept', 'application/json'
      get '/people/1.json'
      expect(response.code).to eq(404)
    end
  end
  describe 'Object Lifecycle for /people' do
    it 'creates an order object, updates it, and deletes it' do
      #Create invalid object
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'
      body({name: 'name', age: 18}.to_json)
      post '/people'
      expect(response.code).to eq(422)
      expect(response.body).to eq({errors:[{age:["must be greater than 18"]}]}.to_json)
      puts "    Successfully verified error response on create"
      #Create valid object
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'
      body({name: 'name', age: 21}.to_json)
      post '/people'
      expect(response.code).to eq(201)
      location = response.headers['Location']
      puts "    Successfully verified create"
      id = location.split('/').last
      #Try to get created object
      get location
      expect(response.code).to eq(200)
      expect(response.headers['Content-Type']).to eq('application/json')
      obj = JSON.parse(response.body)
      expect(obj['name']).to eq('name')
      puts "    Successfully verified created document matches expected"
      #Try to update object to something invalid
      obj['age'] = 17
      body obj.to_json
      put "/people/#{id}"
      expect(response.code).to eq(422)
      expect(response.headers['Content-Type']).to eq('application/json')
      puts "    Successfully verified invalid updates fail"
      #Get object and verify it didn't save invalid
      get "/people/#{id}"
      expect(response.code).to eq(200)
      expect(response.headers['Content-Type']).to eq('application/json')
      obj = JSON.parse(response.body)
      expect(obj['age']).to eq(21)
      puts "    Successfully verified invalid update wasn't applied"
      #Now try a valid update
      obj['name'] = "newname"
      obj['age'] = 21
      body obj.to_json
      put "/people/#{id}"
      expect(response.code).to eq(204)
      expect(response.headers['Content-Type']).to eq('application/json')
      puts "    Successfully submitted valid update"
      #Check that the update applied
      get "/people/#{id}"
      expect(response.code).to eq(200)
      expect(response.headers['Content-Type']).to eq('application/json')
      obj = JSON.parse(response.body)
      expect(obj['name']).to eq('newname')
      puts "    Successfully verified updated document matches expected"
      #Try to delete it
      delete "/people/#{id}"
      expect(response.code).to eq(204)
      puts "    Successfully deleted document"
      #Verify it is gone
      get "/people/#{id}"
      expect(response.code).to eq(404)
      puts "    Successfully verified document was deleted"
    end
  end
end
