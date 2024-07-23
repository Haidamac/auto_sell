class PasswordResetMailer < ApplicationMailer
  def password_reset
    @user = params[:user]
    mail(to: @user.email, subject: 'Password Reset Instructions')
  end
end
