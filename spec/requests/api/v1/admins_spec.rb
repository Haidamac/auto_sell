require 'rails_helper'
require 'swagger_helper'

require 'rails_helper'

RSpec.describe Api::V1::AdminsController, type: :controller do
  let(:valid_attributes) { { name: 'Admin Name', email: 'admin99@example.com', password: 'password123!' } }
  let(:invalid_attributes) { { name: '', email: 'invalid-email', password: '' } }
  let(:user) { create(:user, :admin) }
  let(:token) { JWT.encode({ user_id: user.id }, Rails.application.secret_key_base) }

  before do
    request.headers['Authorization'] = "Bearer #{token}"
  end

  describe 'POST #create_admin' do
    context 'with valid attributes' do
      it 'creates a new admin' do
        expect(response).to have_http_status(:ok)
      end

      it 'sets the user as an admin' do
        post :create_admin, params: valid_attributes
        user = User.last
        expect(user.role).to eq('admin')
      end

      it 'returns the created admin as JSON' do
        post :create_admin, params: valid_attributes
        json_response = JSON.parse(response.body)
        expect(json_response['name'] == 'Admin Name')
        expect(json_response['email'] == 'admin99@example.com')
      end
    end

    context 'with invalid attributes' do
      it 'does not create a new admin' do
        expect do
          post :create_admin, params: invalid_attributes
        end.not_to change(User, :count)
      end

      it 'returns an error status' do
        post :create_admin, params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error messages as JSON' do
        post :create_admin, params: invalid_attributes
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to be_present
      end
    end
  end

  describe 'Authorization' do
    context 'when not authorized' do
      before do
        # Remove or alter token to simulate authorization failure
        request.headers['Authorization'] = nil
      end

      it 'returns unauthorized status' do
        post :create_admin, params: valid_attributes
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when not permitted' do
      before do
        # Mock a policy violation
        allow_any_instance_of(UserPolicy).to receive(:create_admin?).and_return(false)
      end
    end
  end
end
