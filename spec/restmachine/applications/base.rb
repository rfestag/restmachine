require 'mongoid'

Mongoid.load!("mongoid.yml", :production)

Webmachine::ActionView.configure do |config|
  config.view_paths = ['spec/views/']
  config.handlers = [:erb, :haml, :builder]
end
class PersonPolicy < Restmachine::ApplicationPolicy; 
  def not_allowed?
    false
  end
  def action?
    true
  end
  def iaction?
    true
  end
  def schema
    Dry::Validation.Form do
      required(:name).filled(:str?)
      required(:age).filled(:int?, gt?: 18)
    end
  end
  def schema_for_action
    nil
  end
  def schema_for_iaction
    nil
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
module PeopleController
  module ClassMethods
    def action
      {result: true}
    end
    def not_allowed
    end
    def no_policy
    end
  end
  def iaction
    {result: true}
  end
  def inot_allowed
  end
  def ino_policy
  end
  def self.included(base)
    base.extend(ClassMethods)
  end
end

BaseApp = Webmachine::Application.new do |app|
  key = OpenSSL::PKey::EC.new 'prime256v1'
  key.generate_key
  authenticator = Restmachine::Authenticator::JWTCookie.new secret: key do |credential|
    credential
  end

  app.routes do
    resource Person, authenticator: authenticator, controller: PeopleController
  end
end
