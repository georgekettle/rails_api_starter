module Api
  module V1
    class UsersController < BaseController
      def update
        if Current.user.update(user_params)
          render_success(
            data: {
              user: Current.user.as_json(only: [:id, :email, :name]),
              message: 'User updated successfully',
            }
          )
        else
          render_error(
            message: 'Validation failed',
            code: 'validation_error',
            status: :unprocessable_entity,
            details: Current.user.errors.as_json
          )
        end
      end
      
      def update_email
        unless params[:password].present? && params[:email].present?
          return render_error(
            message: 'Email and password are required',
            code: 'missing_parameters',
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

        if Current.user.update(email: params[:email])
          render_success(
            data: {
              user: Current.user.as_json(only: [:id, :email, :name]),
              message: 'Email updated successfully'
            }
          )
        else
          render_error(
            message: 'Validation failed',
            code: 'validation_error',
            status: :unprocessable_entity,
            details: Current.user.errors.as_json
          )
        end
      end
      
      def update_password
        # Validate required parameters
        unless params[:current_password].present? && params[:password].present? && params[:password_confirmation].present?
          return render_error(
            message: 'Current password, password, and password confirmation are required',
            code: 'missing_parameters',
            status: :unprocessable_entity
          )
        end

        # Validate current password
        unless Current.user.authenticate(params[:current_password])
          return render_error(
            message: 'Current password is invalid',
            code: 'invalid_password',
            status: :unauthorized
          )
        end

        # Validate password confirmation
        unless params[:password] == params[:password_confirmation]
          return render_error(
            message: 'Password and password confirmation do not match',
            code: 'password_mismatch',
            status: :unprocessable_entity
          )
        end

        # Update password
        if Current.user.update(password: params[:password])
          render_success(
            data: {
              message: 'Password updated successfully'
            }
          )
        else
          render_error(
            message: 'Validation failed',
            code: 'validation_error',
            status: :unprocessable_entity,
            details: Current.user.errors.as_json
          )
        end
      end
      
      private
      
      def user_params
        params.require(:user).permit(:email, :name, :password, :password_confirmation)
      end
    end
  end
end