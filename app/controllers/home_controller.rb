class HomeController < ApplicationController
  include Devise::Controllers::Helpers
  
  # Removed temporary authenticate_user! placeholder
  # def authenticate_user!
  #   # This is a placeholder to make skip_before_action happy.
  #   # The actual authentication is handled by Devise where needed.
  #   # super unless devise_controller? # We don't want to call the parent authenticate_user! here
  # end
  
  # Reverted to using skip_before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: [:index]

  def index
    @featured_products = Product.featured.limit(8)
    @latest_products = Product.latest.limit(8)
    @blog_posts = BlogPost.published.recent.limit(3)
  end
end 