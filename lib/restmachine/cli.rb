require 'thor'
require 'restmachine'
module Restmachine
  class CLI < Thor
    register(NewGenerator, "new", "new [NAME]", "Generate a new application")
  end 
end
