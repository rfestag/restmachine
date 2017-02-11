require 'mongoid'
require 'webmachine/test'
require 'simplecov'
SimpleCov.start
require 'restmachine'
require './spec/restmachine/applications.rb'
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'restmachine'

Mongoid.load!("mongoid.yml", :production)
 
module Webmachine
  module Test
    def_delegators :current_session, :protect_from_forgery

    class Session
      def protect_from_forgery
        header 'X-XSRF-TOKEN', 'FAKE_XSRF_TOKEN'
        cookie 'XSRF-TOKEN', 'FAKE_XSRF_TOKEN'
      end
    end
  end
end
