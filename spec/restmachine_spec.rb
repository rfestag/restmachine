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
  authenticator = Restmachine::Authenticator::JWTCookie.new secret: key do |credential|
    credential
  end

  app.routes do
    login authenticator, controller: LoginController
    resource Person, authenticator: authenticator
  end
end

describe Restmachine do
  include Webmachine::Test

  let(:app) {MyApp}

  before do
    Person.delete_all
  end

  describe 'Session management' do
    it 'should provide json of user' do
      get '/people'
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/x-www-form-url-encoded'
      post '/login', {params: {valid_credentials: true}}
      expect(response.code).to eq(200)
      expect(response.headers['Content-Type']).to eq('application/json')
      expect(response.body).to eq({name: "Guest"}.to_json)
      header 'Accept', 'application/json'
      get '/people'
    end
  end
  describe 'XSRF (CSRF) prevention' do
    #XSRF protection is done via double-submit. Any protected request must submit
    #both an XSRF-TOKEN cookie and either X-XSRF-TOKEN header of authentication_token parameter
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
  describe 'Encoding management' do
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
  describe 'Object Lifecycle' do
    it 'lists all visible objects' do
      person = Person.create({name: 'person1', age: 21})
      person = Person.create({name: 'person2', age: 22})
      header 'Accept', 'application/json'
      get '/people'
      expect(response.code).to eq(200)
      expect(response.headers['Content-Type']).to eq('application/json')
      people = JSON.parse(response.body)
      expect(people.count).to eq(2)
    end
    it 'fails to get invalid object' do
      header 'Accept', 'application/json'
      get '/people/1'
      expect(response.code).to eq(404)
    end
    it 'gets valid object' do
      person = Person.create({name: 'name', age: 21})
      header 'Accept', 'application/json'
      get "/people/#{person.id}"
      expect(response.code).to eq(200)
      expect(response.headers['Content-Type']).to eq('application/json')
      expect(JSON.parse(response.body)['name']).to eq('name')
      expect(JSON.parse(response.body)['age']).to eq(21)
    end
    it 'gets html for object' do
      person = Person.create({name: 'name', age: 21})
      get "/people/#{person.id}"
      expect(response.code).to eq(200)
      expect(response.headers['Content-Type']).to eq('application/json')
      expect(JSON.parse(response.body)['name']).to eq('name')
      expect(JSON.parse(response.body)['age']).to eq(21)
    end
    it 'fails to create invalid object' do
      #Create invalid object
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'
      protect_from_forgery
      body({name: 'name', age: 18}.to_json)
      post '/people'
      expect(response.code).to eq(422)
      expect(response.body).to eq({errors:[{age:["must be greater than 18"]}]}.to_json)
    end
    it 'creates a valid object' do
      #Create valid object
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'
      protect_from_forgery
      body({name: 'name', age: 21}.to_json)
      post '/people'
      expect(response.code).to eq(201)
      location = response.headers['Location']
      id = location.split('/').last
      expect(Person.find(id).id.to_s).to eq(id)
    end
    it 'fails to apply an invalid update' do
      person = Person.create({name: 'name', age: 21})
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'
      protect_from_forgery
      body({name: 'name', age: 17}.to_json)
      put "/people/#{person.id}"
      expect(response.code).to eq(422)
      expect(response.headers['Content-Type']).to eq('application/json')
      expect(Person.find(person.id).age).to eq(21)
    end
    it 'updates valid object' do
      person = Person.create({name: 'name', age: 21})
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'
      protect_from_forgery
      body({name: 'newname', age: 21}.to_json)
      put "/people/#{person.id}"
      expect(response.code).to eq(204)
      expect(response.headers['Content-Type']).to eq('application/json')
      expect(Person.find(person.id).name).to eq('newname')
    end
    it 'deletes valid object' do
      person = Person.create({name: 'name', age: 21})
      #Try to delete it
      protect_from_forgery
      delete "/people/#{person.id}"
      expect(response.code).to eq(204)
      expect(Person.find(person.id)).to eq(nil)
    end
  end
end
