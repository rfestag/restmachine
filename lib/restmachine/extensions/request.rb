require 'rack'
module Webmachine
  class Request
    def query
      @query ||= parse_nested_query(uri.query)
    end
    def parse_nested_query str
      Rack::Utils.parse_nested_query(str)
    end
  end
end
