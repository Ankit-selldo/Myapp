class Avo::Resources::Cart < Avo::BaseResource
  self.title = :id
  self.description = "Shopping carts in the application"
  self.search = {
    query: -> {
      query.ransack(
        id_eq: params[:q],
        user_name_cont: params[:q],
        m: 'or'
      ).result(distinct: false)
    }
  }
  self.visible_on_sidebar = true
  
  def fields
    field :id, as: :id
    field :user, as: :belongs_to, searchable: true
    field :coupon, as: :belongs_to, searchable: true
    field :session_id, as: :text, hide_on: [:index]
    field :line_items, as: :has_many
    field :products, as: :has_many, through: :line_items
    field :created_at, as: :date_time, readonly: true
    field :updated_at, as: :date_time, readonly: true
  end

  def scopes
    scope :all, default: true
    scope :with_items, -> { query.joins(:line_items).distinct }
    scope :empty, -> { query.left_joins(:line_items).where(line_items: { id: nil }) }
  end
end
