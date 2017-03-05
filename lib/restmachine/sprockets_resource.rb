require 'sprockets'
module Restmachine
  class SprocketsResource < FileResource 
    attr_reader :sprockets

    def self.create root, sources: [], path: nil, authenticator: nil, js_compressor: nil, css_compressor: nil
      Class.new(self) do
        define_method :authenticator do
          authenticator
        end
        if authenticator
          define_method :authenticate do |header,request|
            authenticator.validate_session(header,request)
          end
        end
        define_method :root do
          root
        end
        define_method :sources do
          sources
        end
        define_method :path do
          path
        end
        define_method :js_compressor do
          js_compressor
        end
        define_method :css_compressor do
          css_compressor
        end
      end
    end
    def initialize
      @sprockets = Sprockets::Environment.new(root) do |env|
        env.logger = Logger.new(STDOUT)
        env.js_compressor = js_compressor if js_compressor
        env.css_compressor = css_compressor if css_compressor
      end
      sources.each do |source|
        @sprockets.append_path(source)
      end
    end
    def allowed_methods
      %w(OPTIONS GET)
    end
    def content_types_provided
      [['*/*', :to_file]]
    end
    def resource_exists?
      assets
    end
    def generate_etag
      @etag ||= assets.digest
    end
    def forbidden?
      false
    end
    def to_file
      response.headers['Content-Type'] = assets.content_type
      assets.to_s
    end
    def target
      @target ||= request.uri.path.gsub(path, '')
    end
    def assets
      @assets ||= sprockets.find_asset(target)
    end
  end
end
