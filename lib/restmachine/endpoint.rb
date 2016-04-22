require 'mimemagic'
require 'webmachine'
require 'json'
require 'pundit'
module Restmachine
  module Endpoint
    def self.included klass
      klass.class_eval do
        include Pundit
        include Webmachine::ActionView::Resource
        include Webmachine::Resource::Authentication
      end
    end

    attr_reader :params
    attr_accessor :errors
    attr_accessor :current_user

    def initialize
      @errors = []
    end
    def default_format
      [["application/json", :to_json],
       ["text/html", :to_html]]
    end
    def content_types_provided
      @content_types_provided ||= if format = request.path_info[:_request_format_ext]
        type = MimeMagic.by_extension(format).type
        puts "type: #{type}"
        [[type, "to_#{format}".to_sym]]
      else
        default_format
      end
    end
    def content_types_accepted
      @content_types_accepted = [["application/json", :from_json],
       ["application/x-www-form-url-encoded", :from_form],
       ["multipart/form_data", :from_multipart]]
    end
    def from_json
      @params ||= JSON.parse(request.body.to_s)
      handle_request if respond_to? :handle_request
    rescue JSON::ParserError => e
      @errors << e.message
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
      @params
      handle_request if respond_to? :handle_request
      #TODO: Rescue from parse error?
    end
    def from_multipart
      raise "multipart/form_data not supported yet"
    end
    def unauthorized
      #TOO:Allow user to set body
      403
    end
    def method_missing meth, *args
      raise NoMethodError unless request.path_info[meth]
      request.path_info[meth]
    end
  end
end
