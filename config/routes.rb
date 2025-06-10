Rails.application.routes.draw do
  mount Avo::Engine, at: Avo.configuration.root_path
  devise_for :users, controllers: {
    sessions: 'sessions',
    registrations: 'registrations',
    passwords: 'passwords'
  }, path: '', path_names: {
    sign_up: 'signup',
    sign_in: 'login',
    sign_out: 'logout'
  }
  
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

    resources :coupons
  end

  # Product routes
  resources :products, only: [:index, :show] do  
    member do
      post :add_to_cart
    end
    resources :subscribers, only: [:create]
  end

  # Cart routes
  resource :cart, only: [:show, :update, :destroy] do 
    get 'add/:product_variant_id', to: 'carts#add', as: :add_to
    delete 'remove/:line_item_id', to: 'carts#remove', as: :remove_from
    patch 'update/:line_item_id', to: 'carts#update', as: :update_item
  end
  
  resources :line_items, only: [:create, :update, :destroy]
  
  # Checkout routes
  get '/checkout', to: 'checkouts#new'    
  post '/checkout', to: 'checkouts#create', as: :process_checkout
  get '/checkout/success', to: 'checkouts#success', as: :checkout_success
  get '/checkout/cancel', to: 'checkouts#cancel', as: :checkout_cancel
  
  # Order routes with payment processing
  resources :orders, only: [] do
    member do
      get :payment
      match :payment_callback, via: [:get, :post]
      get :payment_success
      get :payment_failure
      post :create_payment_intent
    end
  end

  # Static pages
  get 'contact', to: 'pages#contact', as: :contact
  get 'shipping-policy', to: 'pages#shipping_policy', as: :shipping_policy
  get 'returns', to: 'pages#returns', as: :returns
  get 'faq', to: 'pages#faq', as: :faq
  get 'terms', to: 'pages#terms', as: :terms
  get 'privacy', to: 'pages#privacy', as: :privacy

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
  get 'verify-email', to: 'registrations#verify_email'
  post 'verify-email', to: 'registrations#verify'
  post 'resend-otp', to: 'registrations#resend_otp'
  
  # PWA routes
  get 'manifest.json', to: 'pwa#manifest', as: :pwa_manifest
  get 'service-worker.js', to: 'pwa#service_worker', as: :pwa_service_worker

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # User related routes
  resource :profile, only: [:show, :edit, :update]
  resources :orders, only: [:index, :show]
  resource :settings, only: [:show, :update]

  get 'unsubscribe/:token', to: 'blog#unsubscribe', as: :unsubscribe_newsletter

  # Error handling routes
  match '/404', to: 'errors#not_found', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
  match '/422', to: 'errors#unprocessable_entity', via: :all

  # Catch-all route for handling unknown URLs
  match '*path', to: 'errors#not_found', via: :all, constraints: lambda { |req|
    req.path.exclude? 'rails/active_storage'
  }

  # Coupon routes
  post 'coupons/apply', to: 'coupons#apply', as: :apply_coupon
  delete 'coupons/remove', to: 'coupons#remove', as: :remove_coupon
end
