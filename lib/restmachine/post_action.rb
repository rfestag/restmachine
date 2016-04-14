require 'webmachine'
require 'json'
module Restmachine
  class PostAction < Endpoint
    def allowed_methods
      ["POST"]
    end
    def resource
      @resource ||= instance_exec &(self.class.controller.find)
    end
    def to_json
      resource.to_json
    end
    def resource_exists?
      resource
    end
  end
end
