class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show, :payment, :payment_callback, :payment_success, :payment_failure, :create_payment_intent]

  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def show
    @order_items = @order.order_items.includes(:product)
    @total_amount = @order.total_amount
  end

  def payment
    @order_items = @order.order_items.includes(:product)
    @total_amount = @order.total_amount

    # Create Stripe payment intent for online payment option
    begin
      if @order.payment_intent_id.blank?
        Rails.logger.info "Creating new payment intent for order #{@order.id}"
        
        intent = Stripe::PaymentIntent.create({
          amount: (@order.total_amount * 100).to_i, # Amount in paise for INR
          currency: 'inr',
          description: "Order ##{@order.number}",
          metadata: {
            order_id: @order.id,
            user_id: current_user.id,
            order_number: @order.number
          },
          receipt_email: current_user.email,
          automatic_payment_methods: {
            enabled: true
          }
        })
        
        @order.update(payment_intent_id: intent.id)
        @client_secret = intent.client_secret
        Rails.logger.info "Payment intent created: #{intent.id}"
      else
        # Retrieve existing payment intent
        Rails.logger.info "Retrieving existing payment intent: #{@order.payment_intent_id}"
        intent = Stripe::PaymentIntent.retrieve(@order.payment_intent_id)
        @client_secret = intent.client_secret
      end
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe error in payment action: #{e.message}"
      flash.now[:alert] = "Payment system error: #{e.message}"
      @client_secret = nil
    rescue => e
      Rails.logger.error "General error in payment action: #{e.message}"
      flash.now[:alert] = "An error occurred. Please try again."
      @client_secret = nil
    end

    render :payment
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Order not found.'
  end

  def create_payment_intent
    begin
      # Convert INR to AED
      amount_in_inr = @order.total_amount
      amount_in_aed = inr_to_aed(amount_in_inr)
      stripe_amount = (amount_in_aed * 100).to_i # Convert to fils

      # Create a PaymentIntent with the order amount and currency
      payment_intent = Stripe::PaymentIntent.create(
        amount: stripe_amount,
        currency: 'aed',
        metadata: {
          order_id: @order.id,
          user_id: current_user.id,
          original_amount_in_inr: amount_in_inr
        },
        receipt_email: current_user.email,
        description: "Order ##{@order.number} - #{@order.order_items.map(&:product).map(&:name).join(', ')}"
      )

      render json: {
        client_secret: payment_intent.client_secret
      }
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe Error: #{e.message}"
      render json: { error: e.message }, status: :unprocessable_entity
    rescue => e
      Rails.logger.error "Error creating payment intent: #{e.message}"
      render json: { error: "An error occurred while processing your payment" }, status: :internal_server_error
    end
  end

  def payment_callback
    @order = current_user.orders.find(params[:id])
    @total_amount = @order.subtotal

    case params[:payment_method]
    when 'cod'
      if @order.update(
        payment_method: 'cod',
        status: :pending,
        payment_status: :pending_payment,
        cod_fee: 50.0
      )
        # Update total with COD fee
        @order.update(total_amount: @order.subtotal + @order.cod_fee)
        
        # Clear the cart after successful order
        current_cart.line_items.destroy_all if current_cart
          
        redirect_to order_path(@order), notice: 'Order placed successfully! You will pay on delivery.'
      else
        redirect_to payment_failure_order_path(@order), alert: 'Failed to process order.'
      end
    when 'online'
      begin
        payment_intent_id = params[:payment_intent_id]
        raise Stripe::InvalidRequestError.new('Payment intent ID is required', 'payment_intent_id') if payment_intent_id.blank?

        Rails.logger.info "Processing payment intent: #{payment_intent_id}"
        payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)
        
        if payment_intent.status == 'succeeded'
          Rails.logger.info "Payment succeeded for order #{@order.id}"
          
          # Create a payment record using the new method
          payment = Payment.create_from_stripe(payment_intent, order: @order, user: current_user)

          if @order.update(
            payment_method: 'online',
            status: :pending,
            payment_status: :paid,
            payment_intent_id: payment_intent_id
          )
            # Clear the cart after successful payment
            current_cart.line_items.destroy_all if current_cart
            
            redirect_to order_path(@order), notice: 'Payment successful! Your order has been placed.'
          else
            raise "Failed to update order status"
          end
        else
          Rails.logger.error "Payment not successful. Status: #{payment_intent.status}"
          raise Stripe::InvalidRequestError.new('Payment not successful', 'payment_intent')
        end
      rescue Stripe::StripeError => e
        Rails.logger.error "Stripe Error: #{e.message}"
        redirect_to payment_failure_order_path(@order), alert: 'Payment failed. Please try again.'
      rescue => e
        Rails.logger.error "Error processing payment: #{e.message}"
        redirect_to payment_failure_order_path(@order), alert: 'An error occurred while processing your payment.'
      end
    else
      redirect_to payment_order_path(@order), alert: 'Invalid payment method selected.'
    end
  end

  def payment_success
    @order_items = @order.order_items.includes(:product)
    @total_amount = @order.total_amount
    render :payment_success
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Order not found.'
  end

  def payment_failure
    @order_items = @order.order_items.includes(:product)
    @total_amount = @order.total_amount
    render :payment_failure
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Order not found.'
  end

  private

  def handle_cod_payment
    if @order.update(
      payment_method: 'cod',
      status: :processing,
      payment_status: :pending_payment,
      cod_fee: 50.0 # Add COD fee if applicable
    )
      # Update total with COD fee
      @order.update(total_amount: @order.subtotal + @order.cod_fee)
      
      # Clear the cart after successful order
      current_cart.line_items.destroy_all if current_cart
      
      redirect_to payment_success_order_path(@order), notice: "Order placed successfully with Cash on Delivery!"
    else
      redirect_to payment_failure_order_path(@order), alert: "Failed to process order"
    end
  end

  def handle_online_payment
    # Get the payment intent from the request
    payment_intent_id = params[:payment_intent_id]
    
    begin
      # Retrieve the payment intent from Stripe
      payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)
      
      if payment_intent.status == 'succeeded'
        # Create a payment record using the new method
        payment = Payment.create_from_stripe(payment_intent, order: @order, user: current_user)

        # Update order status
        if @order.update(
          payment_method: 'online',
          status: :processing,
          payment_status: :paid,
          payment_intent_id: payment_intent_id
        )
          # Clear the cart after successful payment
          current_cart.line_items.destroy_all if current_cart
          
          redirect_to payment_success_order_path(@order), notice: "Payment successful!"
        else
          raise "Failed to update order status"
        end
      else
        raise "Payment not successful"
      end
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe Error: #{e.message}"
      redirect_to payment_failure_order_path(@order), alert: "Payment failed: #{e.message}"
    rescue => e
      Rails.logger.error "Error processing payment: #{e.message}"
      redirect_to payment_failure_order_path(@order), alert: "An error occurred while processing your payment"
    end
  end

  def set_order
    @order = current_user.orders.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Order not found.'
  end

  def inr_to_aed(inr_amount)
    # Convert INR to AED (using a fixed rate for now)
    # You might want to fetch this from an API in production
    (inr_amount / 22.5).round(2)
  end
end 