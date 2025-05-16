module Admin
  class DiscountsController < Admin::BaseController
    before_action :set_discount, only: [:show, :edit, :update, :destroy, :toggle_active]

    def index
      @discounts = Discount.order(created_at: :desc).page(params[:page])
      @discounts = @discounts.where(active: true) if params[:active] == 'true'
      @discounts = @discounts.where('expires_at > ?', Time.current) if params[:valid] == 'true'
    end

    def new
      @discount = Discount.new
    end

    def create
      @discount = Discount.new(discount_params)
      
      if @discount.save
        redirect_to admin_discounts_path, notice: 'Discount was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
      # @discount is already set by the before_action :set_discount
    end

    def edit
    end

    def update
      if @discount.update(discount_params)
        redirect_to admin_discounts_path, notice: 'Discount was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @discount.destroy
      redirect_to admin_discounts_path, notice: 'Discount was successfully deleted.'
    end

    def toggle_active
      @discount.update(active: !@discount.active)
      redirect_to admin_discounts_path, notice: "Discount was successfully #{@discount.active? ? 'activated' : 'deactivated'}."
    end

    private

    def set_discount
      @discount = Discount.find(params[:id])
    end

    def discount_params
      params.require(:discount).permit(
        :code,
        :description,
        :discount_type,
        :amount,
        :minimum_purchase,
        :starts_at,
        :expires_at,
        :active,
        product_ids: []
      )
    end
  end
end 