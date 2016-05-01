require 'securerandom'
require 'bson'
require 'json'
module Restmachine
  module Resource
    module PostAction
      def allowed_methods
        %w(POST)
      end
      def process_post
        send request.path_info[:action].to_sym
      end
    end
  end
end
