class Avo::Resources::LineItem < Avo::BaseResource
  self.title = :id
  self.description = "Items in a shopping cart or order"
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
    # Add fields for relevant LineItem attributes
    # Example:
    # field :quantity, as: :number
    # field :price, as: :number
    # field :product, as: :belongs_to
    # field :cart, as: :belongs_to
    # field :order, as: :belongs_to
    field :created_at, as: :date_time, readonly: true
    field :updated_at, as: :date_time, readonly: true
  end
end 