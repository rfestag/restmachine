require './spec/restmachine/applications/base.rb'
OrderSchema = Dry::Validation.Form(Restmachine::ApplicationSchema) do
  required(:items).filled(:array?)
end
UserSchema = Dry::Validation.Form(Restmachine::ApplicationSchema) do
 required(:email).filled(:str?)
 required(:username).filled(:str?)
 required(:first_name).maybe(:str?)
 required(:last_name).maybe(:str?)
 required(:password).maybe(min_size?: 12).confirmation
 required(:oauth_provider).maybe(:str?)

# rule(password_or_oauth: [:password, :oauth_provider]) do |password, oauth_provider|
#   oauth_provider || password
# end
end
class OrderPolicy < Restmachine::ApplicationPolicy 
  def schema
    OrderSchema
  end
  def create?
    !user.nil?
  end
  def update?
    #Admins can update any order, users can update their own orders
    user.admin or user.id == resource.user_id
  end
  def delete?
    #Only admins can delete orders
    user.admin
  end
end
module OrderController 
  def create attributes
    attributes[:user_id] = current_user.id
    model.create! attributes
  end
end
class UserPolicy < Restmachine::ApplicationPolicy
  def schema
    UserSchema
  end
end
class User
  include Mongoid::Document
  field :username, type: String
  field :admin, type: Boolean

  def uri
    id
  end
end
class Order
  include Mongoid::Document
  field :user_id, type: BSON::ObjectId
  field :items, type: Array

  def uri
    id
  end
end
module LoginController
  def login
    user = User.find_by(username: params['username'])
    if user
      credentials = user.as_document
      credentials[:id] = user.id.to_s
      credentials.delete :_id
    else
      credentials = user
    end
    return credentials
  end
  def logout
  end
end

SecureApp = Webmachine::Application.new do |app|
  key = OpenSSL::PKey::EC.new 'prime256v1'
  key.generate_key
  authenticator = Restmachine::Authenticator::JWTCookie.new secret: key do |credential|
    credential ? User.find(credential['id']) : nil
  end

  app.routes do
    login authenticator, LoginController
    logout authenticator, LoginController
    resource User, authenticator: authenticator
    resource Order, authenticator: authenticator, controller: OrderController
  end
end
