require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'api/v1/cars', type: :request do
  let!(:user) { create(:user, role: 'participant') }
  let(:token) { JWT.encode({ user_id: user.id }, Rails.application.secret_key_base) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  path '/api/v1/cars' do
    get('list car adverts - approved for all / pending and rejected for owner and admins') do
      tags 'Car Adverts'
      produces 'application/json'
      security [jwt_auth: []]
      parameter name: :user_id, in: :query, schema: { type: :integer },
                description: 'Filter on participant'
      parameter name: :status, in: :query, schema: { type: :string },
                description: 'Filter on status: pending/rejected/approved'

      let(:Authorization) { headers['Authorization'] }
      let!(:car1) { create(:car, user:, brand: 'BMW') }
      let!(:car2) { create(:car, user:, brand: 'Tesla') }
      let(:user_id) { nil }
      let(:status) { 'pending' }

      response(200, 'successful') do
        it 'should return status response' do
          expect(response.status).to eq(200)
        end

        run_test!
      end
    end

    post('create new car advert') do
      tags 'Sellers Cars'
      description 'Creates a new car advert'
      consumes 'multipart/form-data'
      security [jwt_auth: []]
      parameter name: :car,
                in: :formData,
                required: true,
                schema: {
                  type: :object,
                  properties: {
                    brand: { type: :string },
                    car_model: { type: :string },
                    body: { type: :string },
                    mileage: { type: :number, format: :float },
                    color: { type: :string },
                    price: { type: :number, format: :float },
                    fuel: { type: :string },
                    year: { type: :integer },
                    volume: { type: :number, format: :float },
                    'images[]':
                      {
                        type: :array,
                        items:
                          { type: :string,
                            format: :binary }
                      }
                  },
                  required: %i[brand car_model body mileage color price fuel year volume]
                }

      response(200, 'ok') do
        let(:Authorization) { headers['Authorization'] }
        let(:car) { attributes_for(:car).merge(user_id: user.id) }

        before do
          post '/api/v1/cars', params: { car: }, headers:
        end

        it 'should return status response' do
          expect(response.status).to eq(200)
          json = JSON.parse(response.body).deep_symbolize_keys
        end

        run_test!
      end

      response(401, 'unauthorized') do
        let(:Authorization) { nil }
        let(:car) { attributes_for(:car).merge(user_id: user.id) }

        run_test! do
          expect(response.status).to eq(401)
        end
      end

      response(422, 'invalid request') do
        let(:Authorization) { headers['Authorization'] }
        let(:car) do
          { brand: nil, car_model: '', body: '', mileage: nil, color: '', price: nil, fuel: '', year: nil, volume: nil, user_id: user.id }
        end

        run_test! do
          expect(response.status).to eq(422)
        end
      end
    end
  end

  path '/api/v1/cars/{id}' do
    parameter name: :id, in: :path, type: :string, description: 'car id'
    let(:Authorization) { headers['Authorization'] }
    let!(:car) { create(:car, user:) }

    get('show car advert - approved for all / pending and rejected for owner and admins') do
      tags 'Car Adverts'
      security [jwt_auth: []]

      response(200, 'successful') do
        let(:id) { car.id }

        it 'should return status response' do
          expect(response.status).to eq(200)
        end

        run_test!
      end

      response(404, 'not found') do
        let(:id) { 'invalid' }

        it 'should return status response' do
          expect(response.status).to eq(404)
        end

        run_test!
      end
    end

    put('update car advert by owner only') do
      tags 'Sellers Cars'
      consumes 'multipart/form-data'
      security [jwt_auth: []]
      parameter name: :car,
                in: :formData,
                schema: {
                  type: :object,
                  properties: {
                    brand: { type: :string },
                    car_model: { type: :string },
                    body: { type: :string },
                    mileage: { type: :number, format: :float },
                    color: { type: :string },
                    price: { type: :number, format: :float },
                    fuel: { type: :string },
                    year: { type: :integer },
                    volume: { type: :number, format: :float },
                    'images[]':
                      {
                        type: :array,
                        items:
                          { type: :string,
                            format: :binary }
                      }
                  }
                }

      response(200, 'successful') do
        let(:id) { car.id }
        let(:Authorization) { headers['Authorization'] }

        it 'returns a 200 response' do
          expect(response).to have_http_status(:ok)
        end

        run_test! do
          car.update(brand: 'The Ukrainian Motors')
          expect(Car.find_by(brand: 'The Ukrainian Motors')).to eq(car)
          car.update(color: 'Maroon')
          expect(Car.find_by(color: 'Maroon')).to eq(car)
        end
      end

      response(401, 'unauthorized') do
        let(:id) { car.id }
        let(:Authorization) { nil }

        run_test! do
          expect(response.status).to eq(401)
        end
      end

      response(404, 'not found') do
        let(:id) { 'invalid' }
        let(:Authorization) { headers['Authorization'] }

        run_test! do
          expect(response.status).to eq(404)
        end
      end
    end

    patch('update status (approved/rejected) by admin') do
      tags 'Admins Cars'
      consumes 'application/json'
      security [jwt_auth: []]
      parameter name: :car,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  properties: {
                    status: { type: :string }
                  }
                }

      response(200, 'successful') do
        let(:id) { car.id }
        let(:Authorization) { headers['Authorization'] }

        it 'returns a 200 response' do
          expect(response).to have_http_status(:ok)
        end

        run_test! do
          car.update(status: 'approved')
          expect(Car.find_by(status: 'approved')).to eq(car)
          car.update(status: 'rejected')
          expect(Car.find_by(status: 'rejected')).to eq(car)
        end
      end

      response(401, 'unauthorized') do
        let(:id) { car.id }
        let(:Authorization) { nil }

        run_test! do
          expect(response.status).to eq(401)
        end
      end

      response(404, 'not found') do
        let(:id) { 'invalid' }
        let(:Authorization) { headers['Authorization'] }

        run_test! do
          expect(response.status).to eq(404)
        end
      end
    end

    delete('delete car adverts - for admin all, for participant his own only') do
      tags 'Sellers Cars'
      security [jwt_auth: []]

      response(200, 'ok') do
        let(:id) { car.id }
        let(:Authorization) { headers['Authorization'] }

        run_test! do
          expect(response.status).to eq(200)
        end
      end

      response(401, 'unauthorized') do
        let(:id) { car.id }
        let(:Authorization) { nil }

        run_test! do
          expect(response.status).to eq(401)
        end
      end

      response(404, 'not found') do
        let(:id) { 'invalid' }

        run_test! do
          expect(response.status).to eq(404)
        end
      end
    end
  end
end
