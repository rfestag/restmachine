SprocketsApp = Webmachine::Application.new do |app|
  app.routes do
    assets 'spec/assets', js_compressor: :yui
  end
end
