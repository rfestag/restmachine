require 'active_support/inflector'
module Restmachine
  module Extensions
    module Dispatcher
      def resource model, *args, path: nil, controller: nil, authenticator: nil, &block
        path ||= "/#{model.name.pluralize.underscore}"
        opts = {path: path, controller: controller, authenticator: authenticator}
        collection = Restmachine::Resource::Collection.create(model, opts) 
        item = Restmachine::Resource::Item.create(model, opts)
        add "#{path}.?:format?", collection, *args, &block 
        add "#{path}/:id.?:format?", item, *args, &block
      end
      def login authenticator, *args, path: nil, controller: nil, &block
        path ||= "/login"
        opts = {path: path, authenticator: authenticator, controller: controller}
        add path, Restmachine::Session::Login.create(opts), *args, &block
      end
      def logout authenticator, *args, path: nil, controller: nil, &block
        path ||= "/logout"
        opts = {path: path, authenticator: authenticator, controller: controller}
        add path, Restmachine::Session::Login.create(opts), *args, &block
      end
    end
  end
end
module Webmachine
  class Dispatcher
    prepend Restmachine::Extensions::Dispatcher
  end
end
