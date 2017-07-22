require 'spec_helper'

describe Restmachine::Resource do
  include Webmachine::Test

  let(:app) {BaseApp}

  before do
    Person.delete_all
  end

  describe 'Custom actions' do
    it 'returns 200 when calling a supported "class" action' do
      header 'Accept', 'application/json'
      protect_from_forgery
      post '/people/action'
      expect(response.code).to eq(200)
      expect(response.headers['Content-Type']).to eq('application/json')
    end
    it 'returns 404 when the "class" action is undefined' do
      header 'Accept', 'application/json'
      protect_from_forgery
      post '/people/no_action'
      expect(response.code).to eq(404)
    end
    it 'returns 403 when the "class" action is defined, but user does not have permission' do
      header 'Accept', 'application/json'
      protect_from_forgery
      post '/people/not_allowed'
      expect(response.code).to eq(403)
    end
    it 'returns 403 when the "class" action is defined, but no policy is defined for it' do
      header 'Accept', 'application/json'
      protect_from_forgery
      post '/people/no_policy'
      expect(response.code).to eq(403)
    end
    it 'returns 200 when calling a supported "instance" action' do
      person = Person.create({name: 'name', age: 21})
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'
      protect_from_forgery
      body({id: 'bob'}.to_json)
      post "/people/#{person.id}/iaction"
      expect(response.code).to eq(200)
      expect(response.headers['Content-Type']).to eq('application/json')
    end
    it 'returns 404 when the "instance" action is undefined' do
      person = Person.create({name: 'name', age: 21})
      header 'Accept', 'application/json'
      protect_from_forgery
      post "/people/#{person.id}/ino_action"
      expect(response.code).to eq(404)
    end
    it 'returns 403 when the "instance" action is defined, but user does not have permission' do
      person = Person.create({name: 'name', age: 21})
      header 'Accept', 'application/json'
      protect_from_forgery
      post "/people/#{person.id}/inot_allowed"
      expect(response.code).to eq(403)
    end
    it 'returns 403 when the "instance" action is defined, but no policy is defined for it' do
      person = Person.create({name: 'name', age: 21})
      header 'Accept', 'application/json'
      protect_from_forgery
      post "/people/#{person.id}/ino_policy"
      expect(response.code).to eq(403)
    end
    it 'returns 422 when the "instance" action parameters are invalid' do
      person = Person.create({name: 'name', age: 21})
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'
      protect_from_forgery
      body({id: ''}.to_json)
      post "/people/#{person.id}/iaction"
      expect(response.code).to eq(422)
    end
  end
  describe 'HTML Object Lifecycle' do
    it 'invalid create bounces back to referrer' do
      #Create invalid object
      header 'Accept', 'text/html'
      header 'Content-Type', 'application/json'
      header 'Referrer', 'http://localhost/people/new.html'
      protect_from_forgery
      body({name: 'name', age: 18}.to_json)
      post '/people'
      expect(response.code).to eq(422)
      expect(response.headers['Location']).to eq('http://localhost/people/new.html')
    end
    it 'invalid update bounces back to referrer' do
      person = Person.create({name: 'name', age: 21})
      header 'Accept', 'text/html'
      header 'Content-Type', 'application/json'
      header 'Referrer', 'http://localhost/people/edit.html'
      protect_from_forgery
      body({name: 'name', age: 17}.to_json)
      put "/people/#{person.id}"
      expect(response.code).to eq(422)
      expect(response.headers['Location']).to eq('http://localhost/people/edit.html')
    end
    it 'shows edit page' do
      person = Person.create({name: 'name', age: 21})
      header 'Accept', 'text/html'
      header 'Content-Type', 'application/json'
      body({name: 'name', age: 21}.to_json)
      get "/people/#{person.id}/edit"
      expect(response.code).to eq(200)
    end
    it 'shows new page' do
      person = Person.create({name: 'name', age: 21})
      header 'Accept', 'text/html'
      header 'Content-Type', 'application/json'
      get "/people/new"
      expect(response.code).to eq(200)
    end
     it 'shows "action" page results' do
      person = Person.create({name: 'name', age: 21})
      header 'Accept', 'text/html'
      header 'Content-Type', 'application/json'
      protect_from_forgery
      body({id: 'bob'}.to_json)
      post "/people/#{person.id}/iaction"
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
