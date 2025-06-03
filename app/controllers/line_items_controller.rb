class LineItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart
  before_action :set_line_item, only: [:update, :destroy]

  def create
    @product = Product.find(params[:product_id])
    @variant = ProductVariant.find(params[:variant_id])
    @line_item = @cart.line_items.find_or_initialize_by(product_variant: @variant)
    
    requested_quantity = params[:quantity].to_i
    new_quantity = @line_item.new_record? ? requested_quantity : @line_item.quantity + requested_quantity

    unless @variant.can_add_to_cart?(new_quantity, @cart)
      available = @variant.available_stock
      redirect_back_or_to @product, alert: "Cannot add #{requested_quantity} items. Only #{available} available in stock."
      return
    end

    @line_item.quantity = new_quantity

    if @line_item.save
      redirect_back_or_to cart_path, notice: 'Item added to cart.'
    else
      redirect_back_or_to @product, alert: @line_item.errors.full_messages.join(', ')
    end
  end

  def update
    requested_quantity = params[:line_item][:quantity].to_i
    variant = @line_item.product_variant

    unless variant.can_add_to_cart?(requested_quantity, @cart)
      available = variant.available_stock
      redirect_to cart_path, alert: "Cannot update quantity. Only #{available} available in stock."
      return
    end

    if @line_item.update(quantity: requested_quantity)
      redirect_to cart_path, notice: 'Cart updated successfully.'
    else
      redirect_to cart_path, alert: @line_item.errors.full_messages.join(', ')
    end
  end

  def destroy
    @line_item.destroy
    redirect_to cart_path, notice: 'Item removed from cart.'
  end

  private

  def set_cart
    @cart = current_user.cart || current_user.create_cart
  end

  def set_line_item
    @line_item = @cart.line_items.find(params[:id])
  end

  def line_item_params
    params.require(:line_item).permit(:quantity)
  end
end 