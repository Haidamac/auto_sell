class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticate_request, only: [:create]
  before_action :authorize_policy
  before_action :set_user, only: [:show]
  before_action :edit_user, only: %i[update destroy]

  # GET api/v1/users
  def index
    @users = if params[:role].present?
               User.role_filter(params[:role])
             else
               User.all
             end

    authorize @users

    render json: @users, status: :ok
  end

  # GET api/v1/users/{name}
  def show
    authorize @user

    render json: @user, status: :ok
  end

  # POST api/v1/users
  def create
    @user = User.new(user_params)

    authorize @user

    if @user.save
      render json: @user, status: :created
    else
      render json: { errors: @user.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  # PUT/PATCH api/v1/users/{id}
  def update
    authorize @user

    if @user.update(edit_user_params)
      render json: @user, status: :ok
    else
      render json: { errors: @user.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  # DELETE api/v1/users/{id}
  def destroy
    authorize @user

    if @user.destroy
      render json: { status: 'Delete' }, status: :ok
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = policy_scope(User).find(params[:id])
  end

  def edit_user
    @user = UserPolicy::EditScope.new(current_user, User).resolve.find(params[:id])
  end

  def user_params
    params.permit(:name, :email, :password, :phone)
  end

  def edit_user_params
    params.permit(policy(@user).permitted_attributes)
  end

  def authorize_policy
    authorize User
  end
end
