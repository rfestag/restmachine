require 'thor'
module Restmachine
  module GemfileHelpers
    # Cleans up a Gemfile by inserting missing newlines between gem statements
    # Fixes old 'bug', where gem statements would be inserted into Gemfile without newlines
    # ==== Examples
    #
    # cleanup_gemfile    
    def cleanup_gemfile
      # add newline between each gem statement in Gemfile
      gsub_file gemfile, /('|")gem/, "\\1\ngem"      
    end

    # Determine if there is a gem statement in a text for a certain gem
    # ==== Parameters
    # text<String>:: text to search for gem statement
    # gem_name<String>:: name of gem to search for
    # ==== Examples
    #
    # has_gem? 'rspec' 
    
    # Note: Should allow for gem version.
    # Should instead use ruby_traverser_dsl (gem on github) which uses ripper2ruby
    def has_gem?(text, gem_name)        
      if /\n[^#]*gem\s*('|")\s*#{Regexp.escape(gem_name)}\s*\1/i.match(text)  
        true 
      else
        false
      end      
    end

    # Quick helper for adding a single gem statement to the Gemfile
    # ==== Parameters
    # gem_name<String>:: gem name
    # gem_version<String>:: gem version string
    # ==== Examples
    #
    #   add_gem 'rspec' 
    #   add_gem 'rspec', '>= 2.0' 
    def add_gem(gem_name, gem_version = nil)
      if !has_gem?(gemfile_txt, gem_name) 
        gem_version_str = gem_version ? ", '#{gem_version}'" : '' 
        append_to_file gemfile, "gem '#{gem_name}'#{gem_version_str}"  
      end
    end

    # Quick helper for adding multiple gem statements to the Gemfile
    # ==== Parameters
    # gem_names<String>:: list of gem names to add
    #
    # ==== Examples
    #
    #   add_gems 'rspec', 'cucumber', 'mocha'
    def add_gems(*gem_names)
      gem_names.each{|gem_name| add_gem(gem_name) }
    end

    # Loads and caches the current Gemfile content
    def gemfile_txt
      @gemfile_txt ||= File.open(gemfile).read        
    end 
    def gemfile
      @gemfile = "#{name}/Gemfile"
    end
  end
end
