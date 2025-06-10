require 'stripe'

class CheckoutsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart
  before_action :ensure_cart_not_empty, only: [:new, :create]
  before_action :set_order, only: [:show, :update, :payment, :payment_callback, :create_payment_intent]
  before_action :check_order_status, only: [:show, :update, :payment]
  before_action :check_payment_status, only: [:show, :update]

  def new
    @order = Order.new
    if current_user
      address_info = current_user.build_address_from_profile
      @order.assign_attributes(address_info) if address_info.values.any?(&:present?)
    end
  end

  def create
    @order = current_user.orders.build(order_params)
    
    # Log the parameters for debugging
    Rails.logger.info "Creating order with params: #{order_params.inspect}"
    
    @order.build_from_cart(@cart)
    @order.status = :pending
    @order.payment_status = :pending_payment

    if @order.save
      # Log successful order creation
      Rails.logger.info "Order created successfully with ID: #{@order.id}"
      Rails.logger.info "Redirecting to: #{payment_order_path(@order)}"
      
      session[:current_order_id] = @order.id
      redirect_to payment_order_path(@order), allow_other_host: true
    else
      # Log validation errors
      Rails.logger.error "Order creation failed with errors: #{@order.errors.full_messages}"
      Rails.logger.error "Order attributes: #{@order.attributes.inspect}"
      
      flash.now[:alert] = "Could not create order: #{@order.errors.full_messages.join(', ')}"
      render :new, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Error in checkout create: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    flash.now[:alert] = "An error occurred while processing your order. Please try again."
    render :new, status: :unprocessable_entity
  end

  def show
    @addresses = current_user.addresses
    @order_items = @order.order_items.includes(:product)
    @total_amount = @order.total_amount
  end

  def update
    if @order.update(order_params)
      redirect_to payment_checkout_path(@order), notice: 'Order was successfully updated.'
    else
      @addresses = current_user.addresses
      @order_items = @order.order_items.includes(:product)
      @total_amount = @order.total_amount
      render :show
    end
  end

  def payment
    @order_items = @order.order_items.includes(:product)
    @total_amount = @order.total_amount
  end

  def payment_callback   #logger is used to log the payment callback
    Rails.logger.info "Payment callback received with params: #{params.inspect}"
    Rails.logger.info "Payment method: #{params[:payment_method]}, Payment Intent ID: #{params[:payment_intent_id]}"

    if params[:payment_method] == 'online'
      Rails.logger.info "Processing online payment for order #{@order.id}"
      
      begin
        payment_intent = Stripe::PaymentIntent.retrieve(params[:payment_intent_id])
        Rails.logger.info "Payment intent status: #{payment_intent.status}"

        if payment_intent.status == 'succeeded'
          @order.transaction do
            # Create payment record
            Payment.create!(
              order: @order,
              user: current_user,
              amount: @order.total_amount,
              payment_id: payment_intent.id,
              status: 'completed',
              payment_details: payment_intent.to_json
            )

            @order.update!(
              status: :processing,
              payment_status: :paid,
              payment_intent_id: params[:payment_intent_id],
              payment_method: 'online'
            )
            
            # Clear the cart after successful payment
            @cart.line_items.destroy_all
            
            # Send confirmation email
            OrderMailer.payment_confirmed(@order).deliver_later
            
            # Redirect to success page
            redirect_to payment_success_order_path(@order), notice: 'Payment successful! Your order has been placed.'
            return
          end
        else
          Rails.logger.error "Payment intent status is not succeeded: #{payment_intent.status}"
          
          # Create failed payment record
          Payment.create!(
            order: @order,
            user: current_user,
            amount: @order.total_amount,
            payment_id: payment_intent.id,
            status: 'failed',
            payment_details: payment_intent.to_json
          )

          @order.update!(
            payment_status: :failed,
            payment_intent_id: params[:payment_intent_id]
          )

          redirect_to payment_failure_order_path(@order), alert: 'Payment failed. Please try again.'
          return
        end
      rescue Stripe::StripeError => e
        Rails.logger.error "Stripe error in payment callback: #{e.message}"
        
        # Create failed payment record
        Payment.create!(
          order: @order,
          user: current_user,
          amount: @order.total_amount,
          payment_id: params[:payment_intent_id],
          status: 'failed',
          payment_details: { error: e.message }.to_json
        )

        @order.update!(
          payment_status: :failed,
          payment_intent_id: params[:payment_intent_id]
        )

        redirect_to payment_failure_order_path(@order), alert: 'Payment processing error. Please try again.'
        return
      end
    else
      # Handle cash on delivery
      @order.transaction do
        # Create pending payment record
        Payment.create!(
          order: @order,
          user: current_user,
          amount: @order.total_amount,
          payment_id: "COD-#{@order.id}",
          status: 'pending',
          payment_details: { method: 'cod' }.to_json
        )

        @order.update!(
          status: :processing,
          payment_status: :pending_payment,
          payment_method: 'cod'
        )
        
        # Clear the cart after order placement
        @cart.line_items.destroy_all
        
        # Send confirmation email
        OrderMailer.payment_confirmed(@order).deliver_later
        
        # Redirect to success page
        redirect_to payment_success_order_path(@order), notice: 'Order placed successfully! Pay on delivery.'
        return
      end
    end
  rescue => e
    Rails.logger.error "Error in payment callback: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    
    # Create failed payment record if possible
    begin
      Payment.create!(
        order: @order,
        user: current_user,
        amount: @order.total_amount,
        payment_id: params[:payment_intent_id] || "ERROR-#{@order.id}",
        status: 'failed',
        payment_details: { error: e.message }.to_json
      )
    rescue => payment_error
      Rails.logger.error "Failed to create payment record: #{payment_error.message}"
    end

    redirect_to payment_failure_order_path(@order), alert: 'An error occurred while processing your payment. Please try again.'
  end

  def payment_success
    @order = current_user.orders.find(params[:id])
    @order_items = @order.order_items.includes(:product)
    @total_amount = @order.total_amount
    render :success
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Order not found.'
  end

  def success
    @order = current_user.orders.find_by(id: params[:order_id])
    if @order
      @order_items = @order.order_items.includes(:product)
      @total_amount = @order.total_amount
      render :success
    else
      redirect_to root_path, alert: 'Order not found.'
    end
  end

  def cancel
    redirect_to cart_path, alert: 'Checkout was cancelled.'
  end

  def apply_coupon
    if @order.apply_coupon(params[:coupon_code])
      render json: {
        success: true,
        message: 'Coupon applied successfully',
        discount: @order.discount_amount,
        total: @order.total_amount
      }
    else
      render json: {
        success: false,
        message: 'Invalid or expired coupon code'
      }, status: :unprocessable_entity
    end
  end

  def remove_coupon
    @order.update(coupon: nil, discount_amount: 0)
    render json: {
      success: true,
      message: 'Coupon removed successfully',
      total: @order.total_amount
    }
  end

  def create_payment_intent
    begin
      # Convert INR to AED
      amount_in_inr = @order.total_amount
      amount_in_aed = inr_to_aed(amount_in_inr)
      stripe_amount = (amount_in_aed * 100).to_i # Stripe expects amount in fils (cents)

      Rails.logger.info "Creating payment intent for order #{@order.id} with amount: #{stripe_amount} AED"

      payment_intent = Stripe::PaymentIntent.create(
        amount: stripe_amount,
        currency: 'aed',
        payment_method_types: ['card'],
        metadata: {
          order_id: @order.id,
          user_id: current_user.id,
          original_amount_in_inr: amount_in_inr
        },
        receipt_email: current_user.email,
        description: "Order ##{@order.id} - #{@order.order_items.map(&:product).map(&:name).join(', ')}"
      )

      Rails.logger.info "Payment intent created successfully: #{payment_intent.id}"

      render json: { 
        client_secret: payment_intent.client_secret,
        payment_intent_id: payment_intent.id
      }
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe Error: #{e.message}"
      render json: { error: e.message }, status: :unprocessable_entity
    rescue StandardError => e
      Rails.logger.error "Payment Intent Creation Error: #{e.message}"
      render json: { error: 'An error occurred while creating the payment intent.' }, status: :internal_server_error
    end
  end

  private

  def set_cart
    @cart = current_user.cart || current_user.create_cart
  end

  def ensure_cart_not_empty
    if @cart.line_items.empty?
      redirect_to cart_path, alert: 'Your cart is empty. Please add some items before proceeding to checkout.'
    end
  end

  def set_order
    @order = current_user.orders.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Order not found.'
  end

  def check_order_status
    # Allow modification if order is pending or pending_payment
    unless @order.pending? || @order.payment_status == 'pending_payment'
      redirect_to root_path, alert: 'This order cannot be modified.'
    end
  end

  def check_payment_status
    # Only check payment status if order is not pending_payment
    if @order.paid? && !@order.pending?
      redirect_to root_path, alert: 'This order has already been paid.'
    end
  end

  def order_params
    params.require(:order).permit(
      :shipping_name,
      :shipping_address,
      :shipping_city,
      :shipping_state,
      :shipping_postal_code,
      :shipping_country,
      :phone,
      :email,
      :shipping_address_id,
      :billing_address_id
    )
  end

  def inr_to_aed(amount_in_inr)
    (amount_in_inr / 22.5).round(2) # Update the rate as needed
  end
end 