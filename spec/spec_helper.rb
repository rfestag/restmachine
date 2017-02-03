require 'simplecov'
SimpleCov.start
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'restmachine'

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
