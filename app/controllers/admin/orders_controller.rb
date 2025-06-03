module Admin
  class OrdersController < BaseController
    before_action :set_order, only: [:show, :update]

    def index
      @orders = Order.includes(:user, :order_items).order(created_at: :desc)
    end

    def show
      @order_items = @order.order_items.includes(:product)
    end

    def update
      previous_status = @order.status
      previous_payment_status = @order.payment_status
      
      if @order.update(order_params)
        # Handle order status changes
        if @order.saved_change_to_status?
          # Handle order cancellation
          if @order.cancelled?
            # Return items to inventory
            @order.order_items.each do |item|
              product = item.product
              product.increment!(:inventory_count, item.quantity)
            end
          end

          # Send status update email based on new status
          case @order.status
          when 'cancelled'
            OrderMailer.order_cancelled(@order).deliver_later
            flash[:notice] = 'Order has been cancelled and inventory has been restored.'
          when 'completed'
            OrderMailer.order_completed(@order).deliver_later
            flash[:notice] = 'Order has been marked as completed.'
          when 'processing'
            OrderMailer.order_processing(@order).deliver_later
            flash[:notice] = 'Order is now being processed.'
          when 'shipped'
            OrderMailer.order_shipped(@order).deliver_later
            flash[:notice] = 'Order has been marked as shipped.'
          when 'delivered'
            OrderMailer.order_delivered(@order).deliver_later
            flash[:notice] = 'Order has been marked as delivered.'
          when 'pending'
            OrderMailer.order_status_update(@order, previous_status).deliver_later
            flash[:notice] = 'Order has been marked as pending.'
          end
        end

        # Handle payment status changes
        if @order.saved_change_to_payment_status?
          case @order.payment_status
          when 'paid'
            OrderMailer.payment_confirmed(@order).deliver_later
            flash[:notice] = flash[:notice].present? ? "#{flash[:notice]} Payment has been confirmed." : 'Payment has been confirmed.'
          when 'refunded'
            OrderMailer.payment_refunded(@order).deliver_later
            flash[:notice] = flash[:notice].present? ? "#{flash[:notice]} Payment has been refunded." : 'Payment has been refunded.'
          when 'failed'
            OrderMailer.payment_failed(@order).deliver_later
            flash[:notice] = flash[:notice].present? ? "#{flash[:notice]} Payment has failed." : 'Payment has failed.'
          else
            OrderMailer.payment_status_update(@order, previous_payment_status).deliver_later
            flash[:notice] = flash[:notice].present? ? "#{flash[:notice]} Payment status has been updated." : 'Payment status has been updated.'
          end
        end

        redirect_to admin_order_path(@order)
      else
        redirect_to admin_order_path(@order), alert: 'Failed to update order.'
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
      params.require(:order).permit(:status, :payment_status)
    end
  end
end 