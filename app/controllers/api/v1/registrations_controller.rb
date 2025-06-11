module Api
  module V1
    class RegistrationsController < BaseController
      skip_before_action :authenticate_user!, only: [:create]
      
      def create
        user = User.new(user_params)
        
        if user.save
          # Create session for the new user
          session = user.sessions.create!(
            user_agent: request.user_agent,
            ip_address: request.remote_ip
          )
          
          render_success(
            data: {
              user: user.as_json(only: [:id, :email, :name]),
              token: session.token
            },
            status: :created
          )
        else
          render_error(
            message: 'Validation failed',
            code: 'validation_error',
            status: :unprocessable_entity,
            details: user.errors.as_json
          )
        end
      end
      
      def destroy
        unless params[:password].present?
          return render_error(
            message: 'Password is required to delete account',
            code: 'password_required',
            status: :unprocessable_entity
          )
        end

        unless Current.user.authenticate(params[:password])
          return render_error(
            message: 'Invalid password',
            code: 'invalid_password',
            status: :unauthorized
          )
        end

        if Current.user.destroy
          render_success(
            data: {
              message: 'Account deleted successfully'
            }
          )
        else
          render_error(
            message: 'Failed to delete account',
            code: 'deletion_failed',
            status: :unprocessable_entity
          )
        end
      end
      
      private
      
      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation, :name)
      end
    end
  end
end 