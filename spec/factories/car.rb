FactoryBot.define do
  factory :car do
    brand { 'Toyota' }
    car_model { 'Corolla' }
    body { 'Sedan' }
    mileage { 50_000.0 }
    color { 'Blue' }
    price { 20_000.0 }
    fuel { 'Petrol' }
    year { 2018 }
    volume { 1.8 }
    status { 'pending' }
    association :user, factory: :user
  end
end
