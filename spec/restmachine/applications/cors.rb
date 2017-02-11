require './spec/restmachine/applications/base.rb'

module PeopleController
  def allowed_origins
    ['www.valid.com:80']
  end
  def allow_cors
    true
  end
end

CORSApp = Webmachine::Application.new do |app|
  key = OpenSSL::PKey::EC.new 'prime256v1'
  key.generate_key
  authenticator = Restmachine::Authenticator::JWTCookie.new secret: key do |credential|
    credential
  end

  app.routes do
    resource Person, authenticator: authenticator, controller: PeopleController
  end
end
