module Api
  module V1
    class PasswordResetsController < BaseController
      include Authenticate
      skip_before_action :authenticate_user!, only: [:create, :update]

      # POST /api/v1/password/forgot
      def create
        user = User.find_by(email: params[:email]&.downcase)

        if user
          token = PasswordResetToken.generate_unique_secure_token
          user.password_reset_tokens.create!(
            token_digest: PasswordResetToken.digest(token),
            expires_at: 1.hour.from_now
          )

          # Send password reset email
          UserMailer.password_reset(user, token).deliver_now

          render_success(
            data: {
              message: "If an account exists with that email, you will receive password reset instructions."
            }
          )
        else
          # Return the same message even when user is not found to prevent email enumeration
          render_success(
            data: {
              message: "If an account exists with that email, you will receive password reset instructions."
            }
          )
        end
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

        reset_token = PasswordResetToken.unused.find_each do |t|
          break t if PasswordResetToken.valid_token?(token, t.token_digest)
        end

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