# frozen_string_literal: true

module Api
  module V1
    # BaseController serves as the foundation for all API controllers in this version.
    # It includes authentication and error response handling for API requests.
    class BaseController < ApplicationController
      include ErrorResponsesHelper

      protect_from_forgery with: :null_session, prepend: true
      prepend_before_action :authenticate_app

      private

      # Authenticates the application using the AppToken provided in the request headers or parameters.
      # If the token is missing or invalid, it renders an unauthorized or forbidden response.
      #
      # @return [void]
      def authenticate_app
        token = request.headers['AppToken'] || params['apptoken']

        if token.blank?
          render_unauthorized_request('No valid App token provided.') and return
        end

        @app = App.approved.find_by(secret_token: token)

        if @app.nil?
          render_forbidden and return
        end
      end
    end
  end
end
