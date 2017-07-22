require 'json'
module Restmachine
  module Resource
    class Edit < Model
      def allowed_methods
        %w(OPTIONS GET)
      end
      def unauthorized?
        authorize(resource, :edit?)
        @action = 'edit'
        return false
      end
      def to_html
        @resource = model.new
        @errors = errors
        response.headers['Location'] = request.headers['Referrer'] if @errors
        render template: "#{pluralized_name}/#{@action}.html"
      end
      def resource
        #We do it this way for cases where a resource
        #doesn't exist. We don't want to look up more than once
        return @resource if @lookup_done
        @resource = show
        @lookup_done = true
        @resource
      end
      def resource_exists?
        resource
      end
    end
  end
end
