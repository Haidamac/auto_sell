class CarSerializer
  include JSONAPI::Serializer
  attributes :brand, :car_model, :body, :mileage, :color, :price, :fuel, :year, :volume, :status
end
