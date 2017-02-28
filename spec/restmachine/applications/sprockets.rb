SprocketsApp = Webmachine::Application.new do |app|
  app.routes do
    assets 'spec/assets'
  end
end
