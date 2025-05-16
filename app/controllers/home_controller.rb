class HomeController < ApplicationController
  skip_before_action :authenticate, only: [:index]

  def index
    @featured_products = Product.where(featured: true).limit(4)
    @latest_products = Product.order(created_at: :desc).limit(8)
    
    # If no featured products, show latest products instead
    if @featured_products.empty?
      @featured_products = @latest_products.first(4)
    end
    
    @blog_posts = BlogPost.published
                         .order(Arel.sql('COALESCE(published_at, created_at) DESC'))
                         .limit(3)
  rescue StandardError => e
    flash.now[:alert] = "Error loading home page content: #{e.message}"
    @featured_products = []
    @latest_products = []
    @blog_posts = []
  end
end 