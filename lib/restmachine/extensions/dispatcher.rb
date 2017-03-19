require 'active_support/inflector'
#require 'webmachine/sprockets'
module Restmachine
  module Extensions
    module Dispatcher
      def assets root, *args, sources: %w(javascripts stylesheets images), path: "/assets/", authenticator: nil, js_compressor: nil, css_compressor: nil, &block
        opts = {sources: sources, path: path, authenticator: authenticator, js_compressor: js_compressor, css_compressor: css_compressor}
        resource = Restmachine::SprocketsResource.create(root, opts)
        add "#{path}*", resource, *args, &block
      end
      def files dir, *args, path: '/*', authenticator: nil, &block
        opts = {authenticator: authenticator}
        resource = Restmachine::FileResource.create(dir, opts)
        puts "Registering path: #{path}"
        add path, resource, *args, &block
      end
      def resource model, *args, path: nil, controller: nil, authenticator: nil, &block
        path ||= "/#{model.name.pluralize.underscore}"
        opts = {path: path, controller: controller, authenticator: authenticator}
        collection = Restmachine::Resource::Collection.create(model, opts) 
        item = Restmachine::Resource::Item.create(model, opts)
        new = Restmachine::Resource::New.create(model, opts)
        edit = Restmachine::Resource::Edit.create(model, opts)
        action = Restmachine::Resource::Action.create(model, opts)
        add "#{path}.?:format?", collection, *args, &block 
        add "#{path}/new.?:format?", new, *args, &block 
        add "#{path}/:id.?:format?", item, *args, &block
        add "#{path}/:id/edit.?:format?", edit, *args, &block
        add "#{path}/:id/:action.?:format?", action, *args, &block
      end
      def login authenticator, controller, *args, path: nil, &block
        path ||= "/login"
        opts = {path: path, controller: controller}
        add path, Restmachine::Session::Login.create(authenticator, controller, opts), *args, &block
      end
      def logout authenticator, controller, *args, path: nil, &block
        path ||= "/logout"
        opts = {path: path, controller: controller}
        add path, Restmachine::Session::Logout.create(authenticator, controller, opts), *args, &block
      end
    end
  end
end
module Webmachine
  class Dispatcher
    prepend Restmachine::Extensions::Dispatcher
  end
end
