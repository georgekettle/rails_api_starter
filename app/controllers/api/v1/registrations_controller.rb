module Api
  module V1
    class RegistrationsController < BaseController
      def create
        user = User.new(user_params)
        
        if user.save
          # Create session for the new user
          token = Session.generate_unique_secure_token
          session = user.sessions.create!(
            token_digest: Session.digest(token),
            user_agent: request.user_agent,
            ip_address: request.remote_ip,
            last_seen_at: Time.current
          )
          
          render_success(
            data: {
              user: user.as_json(only: [:id, :email, :name]),
              token: token
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
      
      private
      
      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation, :name)
      end
    end
  end
end 