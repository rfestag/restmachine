require 'uri'
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
      def bind(tokens, bindings)
        depth = 0
        spec = @path_spec
        loop do
          case
          when spec.empty? && tokens.empty?
            return depth
          when spec == [Webmachine::Dispatcher::Route::MATCH_ALL_STR]
            return [depth, tokens]
          when spec == [Webmachine::Dispatcher::Route::MATCH_ALL]
            return [depth, tokens]
          when tokens.empty?
            return false
          when Symbol === spec.first
            bindings[spec.first] = URI.decode(tokens.first)
          when spec.first == tokens.first
          else
            if spec.length == 1 and tokens.length == 1
              elements = tokens.first.split('.')
              if elements.length > 1
                format = elements.pop
                if spec.first == elements.join
                  bindings[:_request_format_ext] = URI.decode(format)
                  return depth + 1
                end
              end
            end
            return false
          end
          spec = spec[1..-1]
          tokens = tokens[1..-1]
          depth += 1
        end
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
