module Admin
  class ProductsController < Admin::BaseController
    before_action :set_product, only: [:show, :edit, :update, :destroy]

    def index
      @products = Product.all.order(created_at: :desc)
      @products = @products.search(params[:search]) if params[:search].present?
      @products = @products.by_category(params[:category]) if params[:category].present?
      @products = @products.where(featured: true) if params[:featured] == 'true'
      @products = @products.where('inventory_count < ?', 10) if params[:status] == 'low_stock'
      @products = @products.where(status: params[:status]) if params[:status].present? && params[:status] != 'low_stock'
      @products = @products.page(params[:page]).per(20)
    end

    def show
      @sub_products = @product.sub_products
    end

    def new
      @product = Product.new
    end

    def create
      @product = current_user.products.build(product_params)
      
      if @product.save
        redirect_to admin_products_path, notice: 'Product was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @product.update(product_params)
        respond_to do |format|
          format.html { redirect_to admin_products_path, notice: 'Product was successfully updated.' }
          format.turbo_stream { render turbo_stream: turbo_stream.replace(@product) }
        end
      else
        respond_to do |format|
          format.html { render :edit, status: :unprocessable_entity }
          format.turbo_stream { render turbo_stream: turbo_stream.replace(@product) }
        end
      end
    end

    def destroy
      @product.destroy
      redirect_to admin_products_path, notice: 'Product was successfully deleted.', status: :see_other
    end

    private

    def set_product
      @product = Product.find(params[:id])
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
        :status
      )
    end
  end
end 