require 'json'
module Restmachine
  module Resource
    class New < Model
      def allowed_methods
        %w(OPTIONS GET)
      end
      def forbidden?
        authorize(model, :new?)
        @action = 'new'
        return false
      #Occurs when user access to perform specified action on resource explicitly fails
      rescue Pundit::NotAuthorizedError => e
        handle_unauthorized(e)
        true
      #Occurs when no policy/check is defined the the specified action on resource
      rescue Pundit::NotDefinedError => e
        handle_unauthorized(e)
        true
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
