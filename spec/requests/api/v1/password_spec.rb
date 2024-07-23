require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'api/v1/password', type: :request do
  let!(:user) { create(:user, name: 'Test', email: 'test@example.com', password: 'OldPassword123!') }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }
  let(:token) { JWT.encode({ user_id: user.id }, Rails.application.secret_key_base) }

  path '/api/v1/password/forgot' do
    post('forgot password') do
      tags 'Users'
      description 'forgot users password'
      consumes 'application/json'
      parameter name: :user,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  properties: {
                    email: { type: :string }
                  },
                  required: [:email]
                }

      let(:email) { 'test@example.com' }

      context 'when email is present' do
        before do
          post '/api/v1/password/forgot', params: { email: }, headers:
        end

        it 'returns a status code 200' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns a reset password token' do
          json = JSON.parse(response.body)
          expect(json['reset_password_token']).to be_present
        end
      end

      context 'when email is not present' do
        before do
          post '/api/v1/password/forgot', params: { email: '' }, headers:
        end

        it 'returns an error message' do
          json = JSON.parse(response.body)
          expect(json['error']).to eq('Email not present')
        end
      end

      context 'when email is not found' do
        before do
          post '/api/v1/password/forgot', params: { email: 'nonexistent@example.com' }, headers:
        end

        it 'returns a status code 404' do
          expect(response).to have_http_status(:not_found)
        end

        it 'returns an error message' do
          json = JSON.parse(response.body)
          expect(json['error']).to include('Email address not found. Please check and try again.')
        end
      end
    end
  end

  path '/api/v1/password/reset' do
    post('reset password') do
      tags 'Users'
      description 'reset password'
      consumes 'application/json'
      parameter name: :user,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  properties: {
                    email: { type: :string },
                    password: { type: :string },
                    token: { type: :string }
                  },
                  required: %i[email password token]
                }

      context 'when token is valid' do
        let(:new_password) { 'NewPassword123!' }
        let(:reset_params) do
          {
            token:,
            new_password:
          }
        end

        before do
          post '/api/v1/password/reset', params: reset_params, headers:
        end

        it 'returns a status code 200' do
          expect(response).to have_http_status(:ok)
        end

        it 'resets the user password' do
          user.reload
          expect(user.authenticate(new_password) == user)
        end
      end

      context 'when token is invalid' do
        before do
          post '/api/v1/password/reset', params: { token: 'invalid_token', password: 'NewPassword123!', email: user.email }, headers:
        end

        it 'returns an error message' do
          json = JSON.parse(response.body)
          expect(json['error']).to include('Link not valid or expired. Try generating a new link.')
        end
      end

      context 'when email is missing' do
        before do
          post '/api/v1/password/reset', params: { token:, password: 'NewPassword123!' }, headers:
        end

        it 'returns an error message' do
          json = JSON.parse(response.body)
          expect(json['error']).to eq('Token not present')
        end
      end
    end
  end

  path '/api/v1/password/update' do
    put('update password') do
      tags 'Users'
      description 'update password'
      consumes 'application/json'
      security [jwt_auth: []]
      parameter name: :user,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  properties: {
                    old_password: { type: :string },
                    new_password: { type: :string },
                    confirm_password: { type: :string }
                  },
                  required: %i[old_password new_password confirm_password]
                }

      let(:current_user) { user }
      let(:headers) { { 'Authorization' => "Bearer #{token}" } }
      let(:old_password) { 'OldPassword123!' }
      let(:new_password) { 'NewPassword123!' }
      let(:confirm_password) { 'NewPassword123!' }

      context 'when old password is correct and new passwords match' do
        before do
          put '/api/v1/password/update', params: { old_password:, new_password:, confirm_password: },
                                         headers:
        end

        it 'returns a status code 200' do
          expect(response).to have_http_status(:ok)
        end

        it 'updates the password' do
          user.reload
          expect(user.authenticate(new_password) == user)
        end
      end

      context 'when old password is incorrect' do
        before do
          put '/api/v1/password/update', params: { old_password: 'wrong_password', new_password:, confirm_password: },
                                         headers:
        end

        it 'returns a status code 422' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns an error message' do
          json = JSON.parse(response.body)
          expect(json['error']).to include('Old password is incorrect')
        end
      end

      context 'when new passwords do not match' do
        before do
          put '/api/v1/password/update',
              params: { old_password:, new_password: 'NewPassword123', confirm_password: 'DifferentPassword123' }, headers:
        end

        it 'returns a status code 422' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns an error message' do
          json = JSON.parse(response.body)
          expect(json['error']).to include('New password and confirmation do not match')
        end
      end
    end
  end
end
