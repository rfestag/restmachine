module Restmachine
  module Extensions
    module Dispatcher
      def resource model, *args, &block
        path = "/#{model.name.underscore}"
        collection = Restmachine::Resource::Collection.create(model)
        item = Restmachine::Resource::Item.create(model)
        add path, collection, *args, &block 
        add "#{path}/:id", item, *args, &block
      end
    end
  end
end
module Webmachine
  class Dispatcher
    prepend Restmachine::Extensions::Dispatcher
  end
end
