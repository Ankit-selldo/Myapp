class CartsController < ApplicationController
  before_action :authenticate
  before_action :set_cart

  def show
  end

  private

  def set_cart
    @cart = current_user.cart || current_user.create_cart
  end
end 