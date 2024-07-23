require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'api/v1/admins', type: :request do
  let!(:user) { create(:user, role: 'admin') }
  let(:token) { JWT.encode({ user_id: user.id }, Rails.application.secret_key_base) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }
  let(:Authorization) { headers['Authorization'] }

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
      let(:valid_attributes) { { name: 'Admin2', email: 'admin2@example.com', password: 'Admin123!' } }
      let(:invalid_attributes) { { name: 'Admin3', email: 'admin3@example.com', password: 'pas' } }

      response(201, 'successful created') do
        before do
          puts headers.inspect
          post '/api/v1/admins/create_admin', params: valid_attributes, headers: headers
        end

        it 'creates a new admin' do
          expect(response).to have_http_status(:created)
          json = JSON.parse(response.body)

          expect(json['email']).to eq(valid_attributes[:email])

          new_admin = User.find_by(email: valid_attributes[:email])
          expect(new_admin).not_to be_nil
          expect(new_admin.name).to eq(valid_attributes[:name])
          expect(new_admin.email).to eq(valid_attributes[:email])
          expect(new_admin.admin?).to be_truthy

          expect(new_admin.valid_password?(valid_attributes[:password])).to be_truthy
        end

        run_test!
      end

      response(401, 'unauthorized') do
        before do
          post '/api/v1/admins/create_admin', params: valid_attributes, headers: {}
        end

        it 'returns status response' do
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
          expect(json['errors']).to include("Password is too short (minimum is 8 characters)")
        end

        run_test!
      end
    end
  end
end
