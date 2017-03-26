module Restmachine
  module OAuth
    module Facebook
      def scopes
        %w(public_profile email)
      end
      def scope
        @scope = scopes.join(',')
      end
      def site
        @site ||= 'https://graph.facebook.com/v2.8'
      end
      def token_url
        @token_url ||= site + '/oauth/access_token'
      end
      def authorize_uri
        @authorize_uri ||= site + "/dialog/oauth?client_id=#{app_id}&scope=#{scope}"
      end
      def get_user_info
        token.get('https://graph.facebook.com/me').parsed
      end
    end
  end
end
