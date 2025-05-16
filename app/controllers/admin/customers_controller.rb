module Admin
  class CustomersController < BaseController
    def index
      @customers = User.where(role: :customer)
                      .order(created_at: :desc)
                      .page(params[:page])
                      .per(20)
    end

    def show
      @customer = User.find(params[:id])
      @orders = @customer.orders.order(created_at: :desc).limit(10)
    end

    def edit
      @customer = User.find(params[:id])
    end

    def update
      @customer = User.find(params[:id])
      if @customer.update(customer_params)
        redirect_to admin_customer_path(@customer), notice: 'Customer was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def orders
      @customer = User.find(params[:id])
      @orders = @customer.orders.order(created_at: :desc).page(params[:page])
      render :show
    end

    def wishlist
      @customer = User.find(params[:id])
      @wishlist_items = @customer.wishlist_items.includes(:product).page(params[:page])
      render :show
    end

    private

    def customer_params
      params.require(:user).permit(:name, :email, :role)
    end
  end
end 