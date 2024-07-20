# First Admin Create
user1 = User.create(name:'Admin1',email:'admin1@test.com',password:'Admin123!',role:1)

# Users create
user2 = User.create(name:'Vasia',email:'vasia@test.com',password:'User123!',phone:'+380000000000')
user3 = User.create(name:'Petro',email:'petro@test.com',password:'User123!',phone:'+380000000001')

# Cars create
car1 = Car.create(brand: 'Nissan', car_model: 'Micra', body: 'hatchback', mileage: 120, color: 'red',
                  price: 4800, fuel: 'gas', year: 2013, volume: 1.2, user_id: user2.id)
car1 = Car.create(brand: 'MG', car_model: '4 EV', body: 'hatchback', mileage: 0, color: 'silver',
                  price: 24500, fuel: 'electro', year: 2024, volume: 64, user_id: user3.id)
