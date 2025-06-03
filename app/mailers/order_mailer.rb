class OrderMailer < ApplicationMailer
  def order_confirmation(order)
    @order = order
    @user = order.user

    mail(
      to: @order.email,
      subject: "Order Confirmation - Order ##{@order.id}"
    )
  end

  def order_completed(order)
    @order = order
    mail(
      to: @order.email,
      subject: "Order Completed - Order ##{@order.id}"
    )
  end

  def order_cancelled(order)
    @order = order
    mail(
      to: @order.email,
      subject: "Order Cancelled - Order ##{@order.id}"
    )
  end

  def order_processing(order)
    @order = order
    mail(
      to: @order.email,
      subject: "Order Processing - Order ##{@order.id}"
    )
  end

  def order_shipped(order)
    @order = order
    mail(
      to: @order.email,
      subject: "Order Shipped - Order ##{@order.id}"
    )
  end

  def order_delivered(order)
    @order = order
    mail(
      to: @order.email,
      subject: "Order Delivered - Order ##{@order.id}"
    )
  end

  def order_status_update(order, previous_status)
    @order = order
    @previous_status = previous_status
    mail(
      to: @order.email,
      subject: "Order Status Update - Order ##{@order.id}"
    )
  end

  def payment_confirmed(order)
    @order = order
    mail(
      to: @order.email,
      subject: "Payment Confirmed - Order ##{@order.id}"
    )
  end

  def payment_refunded(order)
    @order = order
    mail(
      to: @order.email,
      subject: "Payment Refunded - Order ##{@order.id}"
    )
  end

  def payment_failed(order)
    @order = order
    mail(
      to: @order.email,
      subject: "Payment Failed - Order ##{@order.id}"
    )
  end

  def payment_status_update(order, previous_status)
    @order = order
    @previous_payment_status = previous_status
    mail(
      to: @order.email,
      subject: "Payment Status Update - Order ##{@order.id}"
    )
  end
end 