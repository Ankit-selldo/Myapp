class Avo::Resources::Coupon < Avo::BaseResource
  self.title = :number
  self.description = "Coupons for discounts"
  self.search = {
    query: -> {
      query.ransack(
        id_eq: params[:q],
        number_cont: params[:q],
        m: 'or'
      ).result(distinct: false)
    }
  }
  self.visible_on_sidebar = true

  def fields
    field :id, as: :id
    field :code, as: :text
    field :discount_type, as: :select, options: { "Fixed Amount" => :fixed_amount, "Percentage" => :percentage }
    field :discount_amount, as: :number
    field :min_purchase_amount, as: :number
    field :max_discount_amount, as: :number
    field :starts_at, as: :date_time
    field :expires_at, as: :date_time
    field :usage_limit, as: :number
    field :used_count, as: :number, readonly: true
    field :active, as: :boolean
    field :created_at, as: :date_time, readonly: true
    field :updated_at, as: :date_time, readonly: true
  end

  def scopes
    scope :all, default: true
    scope :active, -> { query.where(active: true) }
    scope :expired, -> { query.where('expires_at < ?', Time.current) }
    scope :unused, -> { query.where('used_count = 0') }
  end
end 