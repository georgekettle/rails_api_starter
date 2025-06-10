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
      
      private
      
      def user_params
        params.require(:user).permit(:email, :name, :password, :password_confirmation)
      end
    end
  end
end