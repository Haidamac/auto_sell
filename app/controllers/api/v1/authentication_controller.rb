class Api::V1::AuthenticationController < ApplicationController
  skip_before_action :authenticate_request
  before_action :current_user, only: :user_id

  # Post api/v1/auth/login
  def login
    @user = User.find_by_email(params[:email])
    if @user&.authenticate(params[:password])
      token = jwt_encode(user_id: @user.id)
      response.set_header('token', token)
      @user_id = @user.id
      render json: { token:, user_id: @user_id }, status: :ok
    else
      render json: { error: 'unauthorized' }, status: :unauthorized
    end
  end
end
