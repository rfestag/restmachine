require 'restmachine'
require 'mongoid'

Mongoid.load!("mongoid.yml", :production)

class Order
  include Mongoid::Document
end
MyApp = Webmachine::Application.new do |app|
  app.configure do |config|
    config.port = 1234
  end
  app.routes do
    resource Order
    add "/orders/:id", Restmachine::Resource::Item.create(Order)
    add "/orders", Restmachine::Resource::Collection.create(Order)
  end
end
MyApp.run
