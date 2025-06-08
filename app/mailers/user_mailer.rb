class UserMailer < ApplicationMailer
  default from: 'no-reply@example.com' # TODO: Change this to your actual domain

  def password_reset(user, token)
    @user = user
    @reset_url = "#{ENV.fetch('FRONTEND_URL', 'http://localhost:3000')}/reset-password?token=#{token}"
    
    mail(
      to: @user.email,
      subject: 'Reset your password'
    )
  end
end 