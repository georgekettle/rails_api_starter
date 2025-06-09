module Api
  module V1
    class SessionsController < BaseController
      include Authenticate
      
      skip_before_action :authenticate_user!, only: [:create]
      
      # Login
      def create
        result = Authentication::AuthenticateUser.new(
          email: params[:email],
          password: params[:password],
          request_info: client_info
        ).call
        
        render_success(
          data: {
            user: result[:user].as_json(only: [:id, :email, :name]),
            token: result[:token]
          }
        )
      rescue Authentication::ValidationError, Authentication::AuthenticationError => e
        render_error(
          message: e.message,
          code: 'invalid_credentials',
          status: :unauthorized
        )
      end
      
      # Logout
      def destroy
        if current_session
          current_session.destroy
          render_success(data: { message: 'Successfully logged out' })
        else
          render_error(
            message: 'No session found',
            code: 'no_session',
            status: :bad_request
          )
        end
      end
      
      # Get current user info
      def show
        render_success(
          data: {
            user: current_user.as_json(only: [:id, :email, :name]),
            session: current_session.as_json(only: [:created_at])
          }
        )
      end
    end
  end
end 