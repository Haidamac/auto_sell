module CarableUtilities
  extend ActiveSupport::Concern

  def build_images
    params[:images].each do |img|
      @car.images.attach(io: img, filename: img.original_filename)
    end
  end

  def car_json
    render json: {
      data: {
        car: CarSerializer.new(@car),
        image_urls: @car.images.map { |image| url_for(image) }
      }
    }, status: :ok
  end
end
