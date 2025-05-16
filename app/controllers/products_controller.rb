class ProductsController < ApplicationController
  include Authorization
  
  before_action :set_product, only: [:show, :edit, :update, :destroy, :add_to_cart]
  before_action :authenticate, only: [:add_to_cart]
  before_action :require_admin, only: [:new, :create, :edit, :update, :destroy]
  
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  skip_before_action :authenticate, only: [:index, :show]

  def index
    @categories = Product::CATEGORIES
    @category = params[:category]
    @products = Product.includes(:rich_text_description)
                      .with_attached_image
                      .by_category(@category)
                      .search(params[:search])
                      .latest
  end

  def show
    @product = Product.includes(:product_variants)
                     .with_attached_image
                     .with_attached_images
                     .find(params[:id])
    
    # Find related products from the same category, excluding the current product
    @related_products = Product.where(category: @product.category)
                             .where.not(id: @product.id)
                             .with_attached_image
                             .limit(4)
  end

  def new
    @product = Product.new
  end

  def create
    @product = current_user.products.build(product_params)

    if @product.save
      redirect_to @product, notice: 'Product was successfully created.'
    else
      flash.now[:alert] = 'Failed to create product. Please check the form for errors.'
      render :new, status: :unprocessable_entity
    end
  rescue StandardError => e
    flash.now[:alert] = "Error creating product: #{e.message}"
    render :new, status: :unprocessable_entity
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to @product, notice: 'Product was successfully updated.'
    else
      flash.now[:alert] = 'Failed to update product. Please check the form for errors.'
      render :edit, status: :unprocessable_entity
    end
  rescue StandardError => e
    flash.now[:alert] = "Error updating product: #{e.message}"
    render :edit, status: :unprocessable_entity
  end

  def destroy
    @product.destroy
    redirect_to products_path, notice: 'Product was successfully deleted.'
  rescue StandardError => e
    redirect_to products_path, alert: "Error deleting product: #{e.message}"
  end

  def add_to_cart
    unless @product.in_stock?
      redirect_to @product, alert: "Sorry, this product is out of stock"
      return
    end

    # Log the incoming parameters
    Rails.logger.info "Adding to cart - Product: #{@product.name}, Color: #{params[:color]}, Size: #{params[:size]}"
    
    unless params[:color].present? && params[:size].present?
      redirect_to @product, alert: "Please select both color and size"
      return
    end

    unless @product.variant_in_stock?(params[:color], params[:size])
      redirect_to @product, alert: "Sorry, this variant is out of stock"
      return
    end

    # Case-insensitive color matching
    variant = @product.product_variants.where("LOWER(color) = LOWER(?)", params[:color].to_s)
                                    .find_by(size: params[:size])

    unless variant
      Rails.logger.error "Variant not found - Available variants: #{@product.product_variants.pluck(:color, :size)}"
      redirect_to @product, alert: "Please select both color and size"
      return
    end
    
    quantity = params[:quantity].to_i
    available_stock = @product.available_stock(params[:color], params[:size])

    if quantity <= 0
      redirect_to @product, alert: "Please select a valid quantity"
      return
    end

    if quantity > available_stock
      redirect_to @product, alert: "Sorry, only #{available_stock} items available"
      return
    end

    # Ensure user has a cart
    current_user.cart ||= Cart.create(user: current_user)
    
    # Find or initialize line item
    line_item = current_user.cart.line_items.find_or_initialize_by(product_variant: variant)
    
    if line_item.new_record?
      line_item.quantity = quantity
    else
      new_quantity = line_item.quantity + quantity
      if new_quantity > available_stock
        redirect_to @product, alert: "Cannot add more items. Cart would exceed available stock."
        return
      end
      line_item.quantity = new_quantity
    end

    if line_item.save
      redirect_to cart_path, notice: "Added to cart successfully"
    else
      redirect_to @product, alert: line_item.errors.full_messages.join(", ")
    end
  end

  private

  def set_product
    @product = Product.includes(:product_variants)
                     .with_attached_image
                     .with_attached_images
                     .find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :name,
      :description,
      :price,
      :category,
      :featured,
      :inventory_count,
      :image,
      images: []
    )
  end

  def not_found
    flash[:alert] = 'Product not found.'
    redirect_to products_path
  end
end
