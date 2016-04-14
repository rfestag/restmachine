module Restmachine
  module Extensions
    module Route
      def initialize path_spec, *args
        if path_spec.respond_to? :split
         path_spec = path_spec.split("/").map do |component|
            component.start_with?(':') ? component[1..-1].to_sym : component
          end
          path_spec = path_spec.reject {|c| c.blank?}
        end
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
