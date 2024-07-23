class Api::V1::CarsController < ApplicationController
  include Rails.application.routes.url_helpers
  include CarableUtilities

  skip_before_action :authenticate_request, only: %i[index show]
  before_action :current_user, only: %i[index show]
  before_action :authorize_policy
  before_action :set_car, only: :show
  before_action :edit_car, only: %i[update destroy]

  # GET /api/v1/cars
  def index
    @cars = if params[:user_id].present?
              policy_scope(Car).filter_by_participant(params[:user_id])
            elsif params[:status].present?
              policy_scope(Car).filter_by_status(params[:status])
            else
              policy_scope(Car).all
            end

    authorize @cars

    if @cars
      render json: { data: @cars.map do |car|
                             car.as_json.merge(images: car.images.map do |image|
                                                                        url_for(image)
                                                                      end)
                   end }, status: :ok
    else
      render json: @cars.errors, status: :bad_request
    end
  end

  # GET /api/v1/cars/1
  def show
    authorize @car

    car_json
  end

  # POST /api/v1/cars
  def create
    @car = Car.new(car_params.except(:images))

    authorize @car

    build_images if params[:images].present?
    @car = current_user.cars.build(car_params)
    if @car.save
      car_json
    else
      render json: @car.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/cars/1
  def update
    authorize @car

    build_images if params[:images].present?

    if @car.update(edit_car_params.except(:images))
      if @car.approved? && params[:status].present?
        StatusMailer.car_approved(@car.user, @car).deliver_later
      elsif @car.rejected? && params[:status].present?
        StatusMailer.car_rejected(@car.user, @car).deliver_later
      end
      car_json
    else
      render json: @car.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/cars/1
  def destroy
    authorize @car

    if @car.destroy!
      render json: { status: 'Delete' }, status: :ok
    else
      render json: @car.errors, status: :unprocessable_entity
    end
  end

  private

  def set_car
    @car = policy_scope(Car).find(params[:id])
  end

  def edit_car
    @car = CarPolicy::EditScope.new(current_user, Car).resolve.find(params[:id])
  end

  def car_params
    params.require(:car).permit(:brand, :car_model, :body, :mileage, :color, :price, :fuel, :year, :volume, images: [])
  end

  def edit_car_params
    params.permit(policy(@car).permitted_attributes)
  end

  def authorize_policy
    authorize Car
  end
end
