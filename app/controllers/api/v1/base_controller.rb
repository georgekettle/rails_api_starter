module Api
  module V1
    class BaseController < ApplicationController
      include ApiResponse
      include ActionController::MimeResponds
      
      # Ensure JSON is returned for all API requests
      before_action :ensure_json_request
      
      private
      
      def ensure_json_request
        unless request.content_type == 'application/json'
          render_error(
            message: 'Only JSON requests are accepted',
            code: 'unsupported_media_type',
            status: :unsupported_media_type
          )
        end
      end
    end
  end
end 