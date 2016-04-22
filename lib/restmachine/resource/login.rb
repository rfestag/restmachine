require 'securerandom'
require 'json'
module Restmachine
  module Resource
    class Login
      def self.create authenticator, *args
        Class.new(PostAction.new authenticator, :login, *args) do
        end
      end
    end
  end
end
