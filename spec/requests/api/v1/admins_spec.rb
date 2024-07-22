require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'api/v1/admins', type: :request do
  let!(:user) { create(:user, role: 'admin') }
  let(:token) { JWT.encode({ user_id: user.id }, Rails.application.secret_key_base) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  path '/api/v1/admins/create_admin' do
    post('create admin') do
      tags 'Users Admin'
      description 'Creates a new admin'
      consumes 'application/json'
      security [jwt_auth: []]
      parameter name: :user,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  properties: {
                    name: { type: :string },
                    email: { type: :string },
                    password: { type: :string }
                  },
                  required: %i[name email password]
                }

      let(:Authorization) { headers['Authorization'] }
      let(:valid_attributes) { { name: 'Jane Doe', email: 'jane.doe@example.com', password: 'Password1' } }
      let(:invalid_attributes) { { name: '', email: 'jane.doe@example.com', password: 'password' } }


      response(201, 'successful created') do
        before do
          post '/api/v1/admins/create_admin', params: valid_attributes, headers: headers
        end

        it 'creates a new admin' do
          expect(response).to have_http_status(:created)
          json = JSON.parse(response.body)
          expect(json['email']).to eq(valid_attributes[:email])
          expect(User.last.admin?).to be_truthy
        end

        run_test!
      end

      response(401, 'unauthorized') do
        before do
          post '/api/v1/admins/create_admin', params: valid_attributes, headers: {}
        end

        let(:Authorization) { nil }
        it 'should returns status response' do
          expect(response.status).to eq(401)
        end

        run_test!
      end

      response(422, 'invalid request') do
        before do
          post '/api/v1/admins/create_admin', params: invalid_attributes, headers: headers
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns validation failure message' do
          json = JSON.parse(response.body)
          expect(json['errors']).to include("Name can't be blank")
        end

        run_test!
      end
    end
  end
end
