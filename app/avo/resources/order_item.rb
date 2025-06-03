class Avo::Resources::OrderItem < Avo::BaseResource
  self.title = :id
  self.description = "Items in customer orders"
  self.search = {
    query: -> {
      query.ransack(
        id_eq: params[:q],
        product_name_cont: params[:q],
        m: 'or'
      ).result(distinct: false)
    }
  }
  self.visible_on_sidebar = true
  
  def fields
    field :id, as: :id
    field :order, as: :belongs_to
    field :product, as: :belongs_to
    field :quantity, as: :number
    field :unit_price, as: :number
    field :total_price, as: :number, readonly: true
    field :created_at, as: :date_time, readonly: true
    field :updated_at, as: :date_time, readonly: true
  end

  def scopes
    scope :all, default: true
    scope :recent, -> { query.order(created_at: :desc) }
  end
end
