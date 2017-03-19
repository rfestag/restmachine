require 'active_support/inflector'
require 'thor'
module Restmachine
  class NewGenerator < Thor::Group
    include Thor::Actions
    include GemfileHelpers

    attr_accessor :appname
    argument :name
    class_option :database, default: 'mongo'
    class_option :adapter, default: 'reel'
    class_option :gemsource, default: 'https://rubygems.org'
    desc "Generates new application"

    source_root File.expand_path("../../templates", __FILE__)

    def creating_directory
      empty_directory "#{name}/app/controllers"
      empty_directory "#{name}/app/models"
      empty_directory "#{name}/app/policies"
      empty_directory "#{name}/app/schemas"
      empty_directory "#{name}/public"
      destination_root = name
    end
    def copy_gemfile
      template 'Gemfile.erb', "#{name}/Gemfile"
    end
    def copy_database_config
      case options[:database]
      when 'mongo'
        add_gem 'mongoid', '~> 6.1.0'
        template 'mongoid.yaml.erb', "#{name}/config/mongoid.yaml"
        template 'config/mongoid.rb.erb', "#{name}/config/database.rb"
      end
    end
    def copy_application_rb
      self.appname = name.classify
      template 'application.rb.erb', "#{name}/application.rb"
      add_gem 'restmachine', "~> #{Restmachine::VERSION}"
    end
    def copy_authentication_rb
      template 'config/authentication.rb.erb', "#{name}/config/authentication.rb"
    end
    def copy_adapter_rb
      template 'config/adapter.rb.erb', "#{name}/config/adapter.rb"
      case options[:adapter]
      when 'reel'
        add_gem 'reel', '~> 0.6.1' if options[:adapter] == 'reel'
      when 'rack'
        template 'config.ru.erb', "#{name}/config.ru"
      when 'httpkit'
        raise "HTTPKit not supported yet"
      end
    end
    def copy_routes_rb
      template 'config/routes.rb.erb', "#{name}/config/routes.rb"
    end
    def run_bundle_install 
      cleanup_gemfile
      inside name do
        run 'bundle install'
      end
    end
  end
end
