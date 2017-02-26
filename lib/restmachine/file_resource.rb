module Restmachine
  class FileResource < Webmachine::Resource
    include Endpoint

    def self.create dir, authenticator: nil
      Class.new(self) do
        define_method :authenticator do
          authenticator
        end
        if authenticator
          define_method :authenticate do |header,request|
            authenticator.validate_session(header,request)
          end
        end
        define_method :dir do
          dir
        end
      end
    end
    def allowed_methods
      %w(OPTIONS GET)
    end
    def content_types_provided
      [['*/*', :to_file]]
    end
    def resource_exists?
      @exists ||= File.exists? target
    end
    def target
      @target ||= dir + request.uri.path
    end
    def forbidden?
      resource_exists? ? !File.readable?(target) : false
    end
    def to_file
      body = nil
      File.open(target) do |f|
        type = MimeMagic.by_magic(f) || MimeMagic.by_path(target)
        response.headers['Content-Type'] = type ? type.type : 'application/octet-stream'
        body = f.read
      end
      body
    end
  end
end
