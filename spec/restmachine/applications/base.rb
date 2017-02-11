require 'mongoid'

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

BaseApp = Webmachine::Application.new do |app|
  key = OpenSSL::PKey::EC.new 'prime256v1'
  key.generate_key
  authenticator = Restmachine::Authenticator::JWTCookie.new secret: key do |credential|
    credential
  end

  app.routes do
    resource Person, authenticator: authenticator
  end
end
