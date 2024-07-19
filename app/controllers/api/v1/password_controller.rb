class Api::V1::PasswordController < ApplicationController
  skip_before_action :authenticate_request, except: :update

  def forgot
    return render json: { error: 'Email not present' } if params[:email].blank?

    user = User.find_by(email: params[:email])

    if user.present?
      user.generate_password_token!
      PasswordResetMailer.with(user:).password_reset.deliver_later
      render json: { reset_password_token: user.reset_password_token }, status: :ok
    else
      render json: { error: ['Email address not found. Please check and try again.'] }, status: :not_found
    end
  end

  def reset
    token = params[:token]

    return render json: { error: 'Token not present' } if params[:email].blank?

    user = User.find_by(reset_password_token: token)

    if user&.password_token_valid?
      if user.reset_password!(params[:password])
        render json: { status: 'ok' }, status: :ok
      else
        render json: { error: user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: ['Link not valid or expired. Try generating a new link.'] }, status: :not_found
    end
  end

  def update
    user = @current_user
    old_password = params[:old_password]
    new_password = params[:new_password]
    confirm_password = params[:confirm_password]

    if user&.authenticate(old_password)
      if new_password == confirm_password
        user.update(password: new_password)
        render json: { status: 'ok' }, status: :ok
      else
        render json: { error: ['New password and confirmation do not match'] }, status: :unprocessable_entity
      end
    else
      render json: { error: ['Old password is incorrect'] }, status: :unprocessable_entity
    end
  end
end
