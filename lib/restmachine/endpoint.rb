require 'webmachine'
require 'json'
module Restmachine
  module Endpoint
    attr_accessor :params

    def content_types_provided
      [["application/json", :to_json]]
    end
    def content_types_accepted
      [["application/json", :from_json],
       ["application/x-www-form-url-encoded", :from_form],
       ["multipart/form_data", :from_multipart]]
    end
    def is_authorized? authorization_header
      if respond_to? :authenticate
        authenticate authorization_header
      else
        true
      end
    end
    def forbidden?
      (respond_to? :authorized?) ? authorized? : false
    end
    def from_json
      @params ||= JSON.parse(request.body.to_s)
      handle_request if respond_to? :handle_request
    end
    def from_form
      #Perhaps not ideal, but if a parameter is sent multiple times, we want
      #an array. Let the service deal with knowing whether multiple are expected
      @params ||= URI.decode_www_form(request.body.to_s).reduce({}) do |q, (k,v)|
        if q[k]
          q[k] = (q[k].is_a? Array) ? q[k] << v : [q[k], v]
        else
          q[k] = v
        end
      end
      handle_request if respond_to? :handle_request
    end
    def from_multipart
      raise "multipart/form_data not supported yet"
    end
    def method_missing meth, *args
      raise NoMethodError unless request.path_info[meth]
      request.path_info[meth]
    end
  end
end
