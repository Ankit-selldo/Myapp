class Avo::Resources::ProductVariant < Avo::BaseResource
  self.title = :sku
  self.description = "Product variants with different sizes and colors"
  self.search = {
    query: -> {
      query.ransack(
        id_eq: params[:q],
        sku_cont: params[:q],
        color_cont: params[:q],
        size_cont: params[:q],
        m: 'or'
      ).result(distinct: false)
    }
  }
  self.visible_on_sidebar = true

  def fields
    field :id, as: :id
    field :sku, as: :text, readonly: true
    field :product, as: :belongs_to, searchable: true
    field :size, as: :text, required: true
    field :color, as: :text, required: true
    field :inventory_count, as: :number, required: true, min: 0
    field :price_adjustment, as: :number, required: true
    field :price, as: :number, readonly: true, format_using: -> { ActionController::Base.helpers.number_to_currency(value, unit: "₹", precision: 2) }
    field :discount_price, as: :number, min: 0, format_using: -> { ActionController::Base.helpers.number_to_currency(value, unit: "₹", precision: 2) }
    field :image, as: :file, is_image: true
    field :created_at, as: :date_time, readonly: true
    field :updated_at, as: :date_time, readonly: true

    field :line_items, as: :has_many
    field :order_items, as: :has_many
  end

  def scopes
    scope :all, default: true
    scope :in_stock, -> { query.where('inventory_count > 0') }
    scope :out_of_stock, -> { query.where('inventory_count = 0') }
    scope :on_discount, -> { query.where('discount_price > 0') }
  end
end 