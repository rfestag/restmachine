require 'spec_helper'

describe Restmachine::Resource do
  include Webmachine::Test

  let(:app) {BaseApp}

  before do
    Person.delete_all
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
