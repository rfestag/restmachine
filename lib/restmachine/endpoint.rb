require 'seconds'
require 'securerandom'
require 'mimemagic'
require 'webmachine'
require 'json'
require 'pundit'
module Restmachine
  module Endpoint
    def self.included klass
      klass.class_eval do
        include Pundit
        include Webmachine::Decision::Conneg
        include Webmachine::ActionView::Resource
        include Webmachine::Resource::Authentication
      end
    end

    attr_reader :params, :xsrf_token
    attr_accessor :errors
    attr_accessor :current_user

    def initialize
      if xsrf_enabled
        @xsrf_token = request.cookies['XSRF-TOKEN'] || SecureRandom.hex(32)
        response.set_cookie 'XSRF-TOKEN', @xsrf_token, secure: true, expires: xsrf_expiration unless request.cookies['XSRF-TOKEN']
      end
      @errors = []
    end
    def xsrf_enabled
      true
    end
    def xsrf_expiration
      @xsrf_expiration ||= Time.now + xsrf_ttl
    end
    def xsrf_ttl
      @xsrf_ttl ||= 24.hours
    end
    def credential_to_user credential 
      credential
    end
    def allow_null_sessions
      true
    end
    def generate_post_response 
      types = content_types_provided.map {|pair| pair.first }
      content_type = choose_media_type(types, request.accept)
      handler = content_types_provided.find{|ct, _| content_type.type_matches?(Webmachine::MediaType.parse(ct)) }.last
      [content_type, send(handler)]
    end
    def is_authorized? header
      if respond_to? :authenticate
        valid_session = authenticate(header, request) do |credential|
          @current_user = credential_to_user(credential)
        end
        valid_session || allow_null_sessions
      else
        true
      end
    end
    def default_format
      [["application/json", :to_json],
       ["text/html", :to_html]]
    end
    def content_types_provided
      format = request.path_info[:format]
      @content_types_provided ||= if format
        type = MimeMagic.by_extension(format).type
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
    def xsrf_valid?
      request.cookies['XSRF-TOKEN'] == request.headers['X-XSRF-TOKEN']
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
    def unauthorized e
      #TODO: Use the exception to build body/headers
      true
    end
    def handle_exception(e)
      puts e.message
      puts e.backtrace.join("\n")
    end
    def method_missing meth, *args
      raise NoMethodError unless request.path_info[meth]
      request.path_info[meth]
    end
  end
end
