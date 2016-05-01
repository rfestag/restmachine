require 'uri'
module Restmachine
  module Extensions
    module Route
      def initialize path_spec, *args
        path_spec = Restmachine::RouteParser.parse(path_spec).to_spec if path_spec.is_a? String
        super path_spec, *args
      end
    end
  end
end
module Webmachine
  class Dispatcher
    class Route
      prepend Restmachine::Extensions::Route
    end
  end
end
