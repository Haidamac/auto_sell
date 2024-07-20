require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'api/v1/authentication', type: :request do
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

      response(201, 'successful created') do
        it 'should returns status response' do
          expect(response.status).to eq(201)
        end
      end

      response(401, 'unauthorized') do
        it 'should returns status response' do
          expect(response.status).to eq(401)
        end
      end

      response(404, 'not found') do
        it 'should returns status response' do
          expect(response.status).to eq(404)
        end
      end

      response(422, 'invalid request') do
        it 'should returns status response' do
          expect(response.status).to eq(422)
        end
      end
    end
  end
end
