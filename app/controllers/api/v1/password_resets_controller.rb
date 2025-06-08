module Api
  module V1
    class PasswordResetsController < BaseController
      include Authenticate
      skip_before_action :authenticate_user!, only: [:create, :update]

      # POST /api/v1/password/forgot
      def create
        user = User.find_by(email: params[:email]&.downcase)

        if user
          reset_token = user.password_reset_tokens.create!
          UserMailer.password_reset(user, reset_token.token).deliver_now
        end

        # Return the same message regardless of whether user exists to prevent email enumeration
        render_success(
          data: {
            message: "If an account exists with that email, you will receive password reset instructions."
          }
        )
      end

      # POST /api/v1/password/reset
      def update
        token = params[:token]
        password = params[:password]

        if token.blank? || password.blank?
          return render_error(
            message: "Token and password are required.",
            code: "missing_parameters",
            status: :unprocessable_entity
          )
        end

        reset_token = PasswordResetToken.unused.find_by(token: token)

        if reset_token&.valid_for_reset?
          user = reset_token.user
          if user.update(password: password)
            # Mark the token as used
            reset_token.mark_as_used!(request.remote_ip)
            
            render_success(
              data: {
                message: "Password has been reset successfully."
              }
            )
          else
            render_error(
              message: "Password could not be updated.",
              code: "password_update_failed",
              status: :unprocessable_entity,
              details: user.errors.full_messages
            )
          end
        else
          render_error(
            message: "Invalid or expired token.",
            code: "invalid_token",
            status: :unprocessable_entity
          )
        end
      end
    end
  end
end 