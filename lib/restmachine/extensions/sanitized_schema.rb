require 'dry-validation'
module Dry
   module Validation
      def self.SanitizedSchema(base = Schema, **options, &block)
        options[:input_processor] = :sanitizer
        puts options
        self.Schema(base, options, &block)
      end
   end
end
