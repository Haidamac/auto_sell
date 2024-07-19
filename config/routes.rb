Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post '/auth/login', to: 'authentication#login'
      post 'password/forgot', to: 'password#forgot'
      post 'password/reset', to: 'password#reset'
      put 'password/update', to: 'password#update'

      post 'admins/create_admin', to: 'admins#create_admin'

      resource :users
      resource :cars
    end
  end
  # Defines the root path route ("/")
  root 'api/v1/cars#index'
end
