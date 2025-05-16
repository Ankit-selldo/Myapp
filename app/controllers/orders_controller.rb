class OrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    # Replace this with actual order fetching logic if you have an Order model
    @orders = []
  end
end 