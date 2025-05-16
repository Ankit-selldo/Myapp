class SubProductsController < ApplicationController
  include Authorization
  
  before_action :authenticate
  before_action :require_admin
  before_action :set_product
  before_action :set_sub_product, only: [ :edit, :update, :destroy, :remove_image ]

  def new
    @sub_product = @product.sub_products.build
  end

  def create
    @sub_product = @product.sub_products.build(sub_product_params)
    if @sub_product.save
      respond_to do |format|
        format.html { redirect_to @product, notice: "Sub product was successfully created." }
        format.turbo_stream { redirect_to @product, notice: "Sub product was successfully created." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @sub_product.update(sub_product_params)
      respond_to do |format|
        format.html { redirect_to @product, notice: "Sub product was successfully updated." }
        format.turbo_stream { redirect_to @product, notice: "Sub product was successfully updated." }
      end
    else
      flash.now[:alert] = "Failed to update sub product: #{@sub_product.errors.full_messages.join(', ')}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @sub_product.destroy
    respond_to do |format|
      format.html { redirect_to @product, notice: "Sub product was successfully deleted." }
      format.turbo_stream { redirect_to @product, notice: "Sub product was successfully deleted." }
    end
  end

  def remove_image
    image = @sub_product.images.find(params[:image_id])
    image.purge
    
    respond_to do |format|
      format.html { redirect_to edit_product_sub_product_path(@product, @sub_product), notice: "Image was successfully removed." }
      format.turbo_stream { redirect_to edit_product_sub_product_path(@product, @sub_product), notice: "Image was successfully removed." }
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to edit_product_sub_product_path(@product, @sub_product), alert: "Image not found."
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_sub_product
    @sub_product = @product.sub_products.find(params[:id])
  end

  def sub_product_params
    params.require(:sub_product).permit(:name, :price, :color, :size, images: [])
  end
end
