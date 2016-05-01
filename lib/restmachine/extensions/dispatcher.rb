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
      def login authenticator, *args, path: nil
       
      end
    end
  end
end
module Webmachine
  class Dispatcher
    prepend Restmachine::Extensions::Dispatcher
  end
end
