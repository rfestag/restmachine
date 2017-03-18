require 'dry-validation'
module Restmachine
  class ApplicationSchema < Dry::Validation::Schema
    configure do |config|
      #config.messages_file = 'config/locales/en.yml'
      #config.messages = :i18n
      input_processor = :sanitizer
    end
  
    define! do
      # define common rules, if any
    end
  end
end
