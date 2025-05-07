Rails.application.routes.draw do
  # Authentication routes
  resource :session, only: [ :new, :create, :destroy ]
  resources :passwords, param: :token, only: [ :new, :create, :edit, :update ]
  resource :unsubscribe, only: [ :show ]

  # Product routes
  resources :products do
    resources :sub_products do
      member do
        delete :remove_image
      end
    end
    resources :subscribers, only: [ :create ]
  end

  # Blog routes
  resources :blog, only: [ :show ], param: :title

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # Root route
  root "products#index"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "/products", to: "product#index"
  post "/products", to: "products#create"
  get "/products/:id", to: "products#show"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
