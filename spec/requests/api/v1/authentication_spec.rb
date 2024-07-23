require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'api/v1/authentication', type: :request do
  let(:user) { create(:user, name: 'User125', password: 'Password123!', email: 'test@example.com') }

  path '/api/v1/auth/login' do
    post('authentication user') do
      tags 'Users'
      description 'authentication user'
      consumes 'application/json'
      parameter name: :user,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  properties: {
                    email: { type: :string },
                    password: { type: :string }
                  },
                  required: %i[email password]
                }

      context 'when credentials are valid' do
        before do
          post '/api/v1/auth/login', params: { email: user.email, password: 'Password123!' }
        end

        it 'returns a token' do
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json['token']).not_to be_nil
          expect(json['user_id']).to eq(user.id)
        end

        it 'sets the token in the header' do
          expect(response.headers['token']).not_to be_nil
        end
      end

      context 'when credentials are invalid' do
        before do
          post '/api/v1/auth/login', params: { email: user.email, password: 'WrongPassword' }
        end

        it 'returns an unauthorized status' do
          expect(response).to have_http_status(:unauthorized)
          json = JSON.parse(response.body)
          expect(json['error']).to eq('unauthorized')
        end
      end

      context 'when email is missing' do
        before do
          post '/api/v1/auth/login', params: { password: 'Password123!' }
        end

        it 'returns an unauthorized status' do
          expect(response).to have_http_status(:unauthorized)
          json = JSON.parse(response.body)
          expect(json['error']).to eq('unauthorized')
        end
      end

      context 'when password is missing' do
        before do
          post '/api/v1/auth/login', params: { email: user.email }
        end

        it 'returns an unauthorized status' do
          expect(response).to have_http_status(:unauthorized)
          json = JSON.parse(response.body)
          expect(json['error']).to eq('unauthorized')
        end
      end
    end
  end
end
