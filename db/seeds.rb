# First admin create
User.create!(email: 'admin@test.com', password: 'Admin123!', name: 'Admin', role: 1) if Rails.env.development?

# Users create
user1 = User.create(name: 'Vasia', email: 'vasia@test.com', password: 'User123!', phone: '+380000000000')
user2 = User.create(name: 'Petro', email: 'petro@test.com', password: 'User123!', phone: '+380000000001')
user3 = User.create(name: 'foma', email: 'petro@example.com', password: 'User123!', phone: '+380000000002')

# Cars create
Car.create(brand: 'Nissan', car_model: 'Micra', body: 'hatchback', mileage: 120, color: 'red',
           price: 4800, fuel: 'gas', year: 2013, volume: 1.2, user_id: user1.id)
Car.create(brand: 'MG', car_model: '4 EV', body: 'hatchback', mileage: 0, color: 'silver',
           price: 24_500, fuel: 'electro', year: 2024, volume: 64, user_id: user2.id)
Car.create(brand: 'Mercedes-Benz', car_model: 'GLE-Class', body: 'coupe', mileage: 100, color: 'black',
           price: 49_900, fuel: 'hybryd', year: 2018, volume: 3, user_id: user3.id)
Car.create(brand: 'Lincoln', car_model: 'Continental', body: 'sedan', mileage: 86, color: 'red',
           price: 25_000, fuel: 'gas', year: 2020, volume: 3.7, user_id: user1.id)
Car.create(brand: 'Volkswagen', car_model: 'ID.4 Crozz', body: 'hatchback', mileage: 10, color: 'white',
           price: 29_100, fuel: 'electro', year: 2023, volume: 84.8, user_id: user2.id)
Car.create(brand: 'Honda', car_model: 'M-NV', body: 'hatchback', mileage: 1, color: 'white',
           price: 18_800, fuel: 'electro', year: 2023, volume: 58.7, user_id: user3.id)
