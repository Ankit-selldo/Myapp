class CartsController < ApplicationController
  before_action :set_cart
  before_action :set_line_item, only: [:update, :remove]

  def show
  end

  def update
    if @line_item.update(quantity: params[:quantity])
      respond_to do |format|
        format.html { redirect_to cart_path, notice: 'Cart updated successfully.' }
        format.json { render json: { success: true, total: @cart.total_price } }
      end
    else
      respond_to do |format|
        format.html { redirect_to cart_path, alert: 'Failed to update cart.' }
        format.json { render json: { success: false, errors: @line_item.errors }, status: :unprocessable_entity }
      end
    end
  end

  def remove
    @line_item.destroy
    respond_to do |format|
      format.html { redirect_to cart_path, notice: 'Item removed from cart.' }
      format.json { render json: { success: true, total: @cart.total_price } }
    end
  end

  private

  def set_cart
    @cart = current_cart
  end

  def set_line_item
    @line_item = @cart.line_items.find(params[:line_item_id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to cart_path, alert: 'Item not found in cart.' }
      format.json { render json: { success: false, error: 'Item not found' }, status: :not_found }
    end
  end
end 