module Admin
  class OrdersController < BaseController
    before_action :set_order, only: [:show, :update]

    def index
      @orders = Order.includes(:user).order(created_at: :desc).page(params[:page])
    end

    def show
      @order_items = @order.order_items.includes(:product)
    end

    def update
      if @order.update(order_params)
        if @order.status_changed? && @order.shipped?
          OrderMailer.shipping_confirmation(@order).deliver_later
        end
        
        redirect_to admin_order_path(@order), notice: 'Order was successfully updated.'
      else
        render :show, status: :unprocessable_entity
      end
    end

    def update_status
      @order = Order.find(params[:id])
      if @order.update(status: params[:status])
        redirect_to admin_order_path(@order), notice: 'Order status updated successfully'
      else
        redirect_to admin_order_path(@order), alert: 'Failed to update order status'
      end
    end

    def update_tracking
      @order = Order.find(params[:id])
      if @order.update(tracking_number: params[:tracking_number])
        redirect_to admin_order_path(@order), notice: 'Tracking number updated successfully'
      else
        redirect_to admin_order_path(@order), alert: 'Failed to update tracking number'
      end
    end

    def pending
      @orders = Order.pending.includes(:user).order(created_at: :desc).page(params[:page])
      render :index
    end

    def shipped
      @orders = Order.shipped.includes(:user).order(created_at: :desc).page(params[:page])
      render :index
    end

    def cancelled
      @orders = Order.cancelled.includes(:user).order(created_at: :desc).page(params[:page])
      render :index
    end

    private

    def set_order
      @order = Order.find(params[:id])
    end

    def order_params
      params.require(:order).permit(:status, :tracking_number, :shipping_address, :payment_status)
    end
  end
end 