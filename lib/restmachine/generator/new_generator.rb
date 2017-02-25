require 'active_support/inflector'
require 'thor'
module Restmachine
  class NewGenerator < Thor::Group
    include Thor::Actions
    include GemfileHelpers

    attr_accessor :appname 
    argument :name
    desc "Generates new application"

    source_root File.expand_path("../../templates", __FILE__)

    def creating_directory
      empty_directory name
      destination_root = name
    end
    def copy_application_rb
      self.appname = name.classify
      template 'application.rb.tt', "#{name}/application.rb"
    end
    def copy_authentication_rb
      template 'config/authentication.rb.tt', "#{name}/config/authentication.rb"
    end
    def copy_config_rb
      template 'config/config.rb.tt', "#{name}/config/config.rb"
    end
    def copy_routes_rb
      template 'config/routes.rb.tt', "#{name}/config/routes.rb"
    end
    def copy_gemfile
      template 'Gemfile.tt', "#{name}/Gemfile"
    end
    def run_bundle_install 
      inside name do
        run 'bundle install'
      end
      #run "cd #{name}; bundle install"
    end
  end
end
