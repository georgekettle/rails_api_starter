Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  # API routes
  namespace :api do
    namespace :v1 do
      # Authentication routes
      post 'signup', to: 'registrations#create'
      delete 'user', to: 'registrations#destroy'
      post 'login', to: 'sessions#create'
      delete 'logout', to: 'sessions#destroy'
      get 'me', to: 'sessions#show'
      
      # Password reset routes
      post 'password/forgot', to: 'password_resets#create'
      post 'password/reset', to: 'password_resets#update'
    end
  end
end
