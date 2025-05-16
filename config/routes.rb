Rails.application.routes.draw do
  devise_for :users
  
  # Admin routes
  namespace :admin do
    root to: 'dashboard#index'
    
    get 'dashboard', to: 'dashboard#index'
    
    resources :products do
      collection do
        get :low_stock
        get :featured
      end
    end
    
    resources :orders do
      member do
        patch :update_status
        patch :update_tracking
      end
      collection do
        get :pending
        get :shipped
        get :cancelled
      end
    end
    
    resources :customers do
      member do
        get :orders
        get :wishlist
      end
    end
    
    resources :discounts do
      member do
        patch :toggle_active
      end
      collection do
        get :active
        get :expired
      end
    end
    
    get 'analytics', to: 'analytics#index'
    get 'analytics/sales', to: 'analytics#sales'
    get 'analytics/customers', to: 'analytics#customers'
    get 'analytics/products', to: 'analytics#products'
    
    get 'settings', to: 'settings#index'
    patch 'settings', to: 'settings#update'
    patch 'settings/theme', to: 'settings#update_theme'
    patch 'settings/notifications', to: 'settings#update_notifications'
    patch 'settings/integrations', to: 'settings#update_integrations'
  end

  # User routes
  resources :products, only: [:index, :show] do
    member do
      post :add_to_cart
    end
    resources :subscribers, only: [:create]
  end

  resource :cart, only: [:show, :update, :destroy]
  resources :line_items, only: [:create, :update, :destroy]
  
  # Authentication routes
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  root 'home#index'

  # Blog routes
  resources :blog_posts, path: 'blog', only: [:index, :show, :new, :create, :edit, :update, :destroy], param: :title do
    resources :comments, only: [:create, :destroy]
    collection do
      post 'subscribe', to: 'blog#subscribe'
    end
  end
  
  resources :newsletter_subscriptions, only: [:create]
  
  # Registration routes
  resources :registrations, only: [:new, :create], path: 'signup', path_names: { new: '' }
  get 'verify-email', to: 'registrations#verify_email'
  post 'verify-email', to: 'registrations#verify'
  post 'resend-otp', to: 'registrations#resend_otp'
  
  # PWA routes
  get 'manifest.json', to: 'pwa#manifest', as: :pwa_manifest
  get 'service-worker.js', to: 'pwa#service_worker', as: :pwa_service_worker

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # Password reset routes
  resources :passwords, only: [:new, :create, :edit, :update]

  # User profile and settings
  resource :profile, only: [:show], controller: 'users'
  resources :orders, only: [:index]
  resource :settings, only: [:show]

  get 'unsubscribe/:token', to: 'blog#unsubscribe', as: :unsubscribe_newsletter
end
