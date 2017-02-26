require 'active_support/inflector'
require 'thor'
module Restmachine
  class NewGenerator < Thor::Group
    include Thor::Actions
    include GemfileHelpers

    attr_accessor :appname, :dbgem, :dbgem_version
    argument :name
    class_option :database, default: 'mongo'
    desc "Generates new application"

    source_root File.expand_path("../../templates", __FILE__)

    def creating_directory
      empty_directory name
      destination_root = name
    end
    def copy_application_rb
      self.appname = name.classify
      template 'application.rb.erb', "#{name}/application.rb"
    end
    def copy_authentication_rb
      template 'config/authentication.rb.erb', "#{name}/config/authentication.rb"
    end
    def copy_adapter
      template 'config/adapter.rb.erb', "#{name}/config/adapter.rb"
    end
    def copy_adapter
      template 'config/database.rb.erb', "#{name}/config/database.rb"
    end
    def copy_routes_rb
      template 'config/routes.rb.erb', "#{name}/config/routes.rb"
    end
    def copy_database_config
      case options[:database]
      when 'mongo'
        @dbgem = 'mongoid'
        @dbgem_version = '~> 6.1.0'
        template 'mongoid.yaml.erb', "#{name}/config/mongoid.yaml"
      end
    end
    def copy_gemfile
      template 'Gemfile.erb', "#{name}/Gemfile"
    end
    def run_bundle_install 
      cleanup_gemfile
      inside name do
        run 'bundle install'
      end
    end
  end
end
