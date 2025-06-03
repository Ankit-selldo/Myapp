module Admin
  class CouponsController < BaseController
    before_action :set_coupon, only: [:show, :edit, :update, :destroy]

    def index
      @coupons = Coupon.order(created_at: :desc)
    end

    def show
    end

    def new
      @coupon = Coupon.new
    end

    def create
      @coupon = Coupon.new(coupon_params)

      if @coupon.save
        redirect_to admin_coupon_path(@coupon), notice: 'Coupon was successfully created.'
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @coupon.update(coupon_params)
        redirect_to admin_coupon_path(@coupon), notice: 'Coupon was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @coupon.destroy
      redirect_to admin_coupons_path, notice: 'Coupon was successfully deleted.'
    end

    private

    def set_coupon
      @coupon = Coupon.find(params[:id])
    end

    def coupon_params
      params.require(:coupon).permit(
        :code, :description, :discount_amount, :minimum_order_amount,
        :discount_type, :usage_limit, :starts_at, :expires_at, :active
      )
    end
  end
end 