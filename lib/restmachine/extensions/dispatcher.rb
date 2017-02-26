require 'active_support/inflector'
#require 'webmachine/sprockets'
module Restmachine
  module Extensions
    module Dispatcher
=begin
      def assets *dirs, path: "/assets/*"
        sprockets = Sprockets::Environment.new
        dirs = dirs.flatten
        dirs.flatten.each {|p| sprockets.append_path p}
        resource = Webmachine::Sprockets.resource_for(sprockets)
        add path, resource
      end
=end
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
        add "#{path}.?:format?", collection, *args, &block 
        add "#{path}/:id.?:format?", item, *args, &block
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
