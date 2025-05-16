module Admin
  class DashboardController < BaseController
    def index
      @total_products = Product.count
      @total_orders = Order.count rescue 0
      @total_users = User.count
      @recent_products = Product.order(created_at: :desc).limit(5)
      @low_stock_products = Product.where('inventory_count <= ?', 10).limit(5)
      @recent_orders = Order.order(created_at: :desc).limit(5)
      @total_sales = Order.completed.sum(:total_amount)
      @order_count = Order.count
      @customer_count = User.where(role: :customer).count
    end
  end
end 