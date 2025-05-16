class LineItemsController < ApplicationController
  before_action :authenticate
  before_action :set_cart
  before_action :set_line_item, only: [:update, :destroy]

  def create
    @product = Product.find(params[:product_id])
    @line_item = @cart.line_items.find_or_initialize_by(product: @product)
    
    if @line_item.new_record?
      @line_item.quantity = 1
    else
      @line_item.quantity += 1
    end

    if @line_item.save
      redirect_back_or_to cart_path, notice: 'Item added to cart.'
    else
      redirect_back_or_to @product, alert: @line_item.errors.full_messages.join(', ')
    end
  end

  def update
    if @line_item.update(line_item_params)
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