require 'json'
module Restmachine
  module Resource
    class New < Model
      def allowed_methods
        %w(OPTIONS GET)
      end
      def unauthorized?
        authorize(model, :new?)
        @action = 'new'
        return false
      end
      def to_html
        @resource = model.new
        @errors = errors
        response.headers['Location'] = request.headers['Referrer'] if @errors
        render template: "#{pluralized_name}/#{@action}.html"
      end
      def resource_exists?
        true
      end
    end
  end
end
