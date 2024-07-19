class Api::V1::AdminsController < ApplicationController
  before_action :authorize_policy

  def create_admin
    @new_admin = User.new(user_params)

    if @new_admin.save
      @new_admin.admin!

      render json: @new_admin, status: :created
    else
      render json: { errors: @new_admin.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:name, :email, :password)
  end

  def authorize_policy
    authorize User
  end
end
