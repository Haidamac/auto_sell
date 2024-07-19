class ApplicationController < ActionController::API
  include JsonWebToken
  include Authenticate
  include Pundit::Authorization

  before_action :authenticate_request

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ArgumentError, with: :invalid_argument

  private

  def authenticate_request
    header = request.headers['Authorization']

    if header.present? && header.split(' ').first == 'Bearer'
      token = header.split(' ').last
      decoded = jwt_decode(token)
      @current_user = User.find(decoded[:user_id])
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def pundit_user
    @current_user
  end

  def user_not_authorized
    render json: { error: 'You are not authorized to perform this action.' }, status: :unauthorized
  end

  def record_not_found
    render json: { error: 'record_not_found' }, status: :not_found
  end

  def invalid_argument
    render json: { error: 'invalid argument' }, status: :unprocessable_entity
  end
end
