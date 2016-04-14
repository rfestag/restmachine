require 'active_support/inflector'
module Restmachine
  module Controller
    def path
      @path ||= model.name.underscore
    end
    def list **opts
      self.class.model.all
    end
    def create
      self.class.model.create(params)
    end
    def find
      self.class.model.find(id)
    end
    def update
      resource.update_attributes(params)
    end
    def delete
      resource.destroy
    end
  end
end
