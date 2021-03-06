require 'mongoid'
require 'restmachine'
require 'celluloid/autostart'

Mongoid.load!("mongoid.yml", :production)

class OrderPolicy < Restmachine::ApplicationPolicy; end
class Order
  include Mongoid::Document
end
MyApp = Webmachine::Application.new do |app|
  app.configure do |config|
    config.port = 1234
#    config.adapter = :Reel
#    config.adapter_options[:spy] = true
  end
  app.routes do
    resource Order
  end
end
puts Order.where(id: id).select([:id]).to_a
#MyApp.run
