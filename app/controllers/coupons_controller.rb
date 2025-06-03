class CouponsController < ApplicationController
  def apply
    @order = current_order
    @coupon = Coupon.find_by(code: params[:code]&.upcase)

    if @coupon.nil?
      render json: { error: 'Invalid coupon code' }, status: :unprocessable_entity
      return
    end

    unless @coupon.available?
      render json: { error: 'This coupon is no longer available' }, status: :unprocessable_entity
      return
    end

    unless @coupon.valid_for_order?(@order.subtotal)
      render json: { 
        error: "This coupon requires a minimum order amount of #{number_to_currency(@coupon.minimum_order_amount, unit: '₹')}"
      }, status: :unprocessable_entity
      return
    end

    discount = @coupon.calculate_discount(@order.subtotal)
    @order.update(coupon: @coupon, discount_amount: discount)

    render json: {
      success: true,
      message: 'Coupon applied successfully!',
      discount: discount,
      total: @order.total_amount,
      html: render_to_string(partial: 'orders/order_summary', locals: { order: @order })
    }
  end

  def remove
    @order = current_order
    @order.update(coupon: nil, discount_amount: 0)

    render json: {
      success: true,
      message: 'Coupon removed successfully!',
      total: @order.total_amount,
      html: render_to_string(partial: 'orders/order_summary', locals: { order: @order })
    }
  end
end 