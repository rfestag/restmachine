FilesApp = Webmachine::Application.new do |app|
  app.routes do
    files 'spec/public'
  end
end
