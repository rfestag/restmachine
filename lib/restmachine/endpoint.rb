require 'seconds'
require 'securerandom'
require 'mimemagic'
require 'webmachine'
require 'json'
require 'pundit'
require 'restmachine/extensions/pundit'
module Restmachine
  class XSRFValidityError < StandardError; end
  module Endpoint
    def self.included klass
      klass.class_eval do
        include Pundit
        include Webmachine::Decision::Conneg
        include Webmachine::ActionView::Resource
        include Webmachine::Resource::Authentication
      end
    end

    attr_reader :params
    attr_accessor :errors
    attr_accessor :current_user

    def initialize
      @errors = []
      @params = {}
      @parsed_params = false
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
      response.headers['Content-Type'] = content_type.type
      response.body = send(handler)
      [content_type, send(handler)]
    end
    def is_authorized? header
      if respond_to? :authenticate
        @current_user = authenticate(header, request)
        !@current_user.nil? || allow_null_sessions
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
    def delete_resource
      raise Restmachine::XSRFValidityError.new("Could not confirm authenticity of request") unless xsrf_valid?
      handle_delete
      true
    rescue Restmachine::XSRFValidityError => e
      @errors << e.message
      403
    end
    def xsrf_valid?
      authenticity_token = request.headers['X-XSRF-TOKEN'] || params['authenticity_token']
      #puts "#{authenticity_token} == #{xsrf_token}"
      !authenticity_token.nil? and xsrf_token == authenticity_token
    end
    def from_json
      #We do this so that we always make params into an object, and only try to parse once
      @params = JSON.parse(request.body.to_s) unless @parsed_params
      @parsed_params = true
      raise Restmachine::XSRFValidityError.new("Could not confirm authenticity of request") unless xsrf_valid?
      handle_request if respond_to? :handle_request
    rescue JSON::ParserError => e
      @errors << e.message
    rescue Restmachine::XSRFValidityError => e
      @errors << e.message
      403
    end
    def from_form
      #Perhaps not ideal, but if a parameter is sent multiple times, we want
      #an array. Let the service deal with knowing whether multiple are expected
      @params = URI.decode_www_form(request.body.to_s).reduce({}) do |q, (k,v)|
        if q[k]
          q[k] = (q[k].is_a? Array) ? q[k] << v : [q[k], v]
        else
          q[k] = v
        end
      end unless @parsed_params
      @parsed_params = true
      raise Restmachine::XSRFValidityError.new("Could not confirm authenticity of request") unless xsrf_valid?
      handle_request if respond_to? :handle_request
      #TODO: Rescue from parse error?
    rescue JSON::ParserError => e
      @errors << e.message
    rescue Restmachine::XSRFValidityError => e
      @errors << e.message
      403
    end
    def from_multipart
      raise "multipart/form_data not supported yet"
    end
    def handle_unauthorized e
      #TODO: Use the exception to build body/headers
    end
    def handle_exception(e)
      puts e.message
      puts e.backtrace.join("\n")
    end
    def finish_request
      response.set_cookie 'XSRF-TOKEN', xsrf_token, secure: true, expires: xsrf_expiration if @xsrf_changed
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
    def generate_xsrf_token
      @xsrf_changed = true
      @xsrf_token = SecureRandom.hex(32)
    end
    def xsrf_token
      @xsrf_token ||= (request.cookies['XSRF-TOKEN'] || generate_xsrf_token)
    end
    def method_missing meth, *args
      raise NoMethodError.new("Couldn't find parameter: #{meth}") unless request.path_info[meth]
      request.path_info[meth]
    end
  end
end
