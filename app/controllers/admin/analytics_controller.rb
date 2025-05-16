module Admin
  class AnalyticsController < BaseController
    def index
      # Date range for analytics
      @date_range = params.fetch(:range, '30_days')
      date_from = case @date_range
                 when '7_days'
                   7.days.ago
                 when '30_days'
                   30.days.ago
                 when '90_days'
                   90.days.ago
                 when '1_year'
                   1.year.ago
                 else
                   30.days.ago
                 end

      # Sales analytics
      @total_sales = Order.completed.sum(:total_amount)
      @sales_by_day = Order.completed
                          .where('created_at >= ?', date_from)
                          .group_by_day(:created_at)
                          .sum(:total_amount)

      # Product analytics
      @top_products = OrderItem.joins(:order, :product)
                              .where(orders: { status: :completed })
                              .group('products.name')
                              .select('products.name, SUM(order_items.quantity) as total_quantity, SUM(order_items.quantity * order_items.price) as total_revenue')
                              .order('total_revenue DESC')
                              .limit(10)

      # Customer analytics
      @new_customers = User.where(role: :customer)
                          .where('created_at >= ?', date_from)
                          .group_by_day(:created_at)
                          .count

      @total_customers = User.where(role: :customer).count
      @total_orders = Order.completed.count
      @average_order_value = @total_orders.zero? ? 0 : @total_sales / @total_orders
    end

    def sales
      # Additional sales analytics
    end

    def customers
      # Customer analytics
    end

    def products
      # Product analytics
    end
  end
end 