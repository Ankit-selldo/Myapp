class Avo::Resources::Product < Avo::BaseResource
  self.title = :name
  self.description = "Products in the store"
  self.search = {
    query: -> {
      query.ransack(id_eq: params[:q], name_cont: params[:q], category_cont: params[:q], m: 'or').result(distinct: false)
    }
  }
  self.visible_on_sidebar = true

  def fields
    field :id, as: :id
    field :name, as: :text, required: true
    field :price, as: :number, format_using: -> { ActionController::Base.helpers.number_to_currency(value, unit: "₹", precision: 2) }
    field :category, as: :select, options: Product::CATEGORIES.transform_keys { |k| [k.titleize, k] }.to_h
    field :inventory_count, as: :number
    field :featured, as: :boolean
    field :image, as: :file, is_image: true
    field :images, as: :files, is_image: true, hide_on: [:index]
    field :description, as: :trix
    field :created_at, as: :date_time, readonly: true
    field :updated_at, as: :date_time, readonly: true

    field :user, as: :belongs_to
    field :product_variants, as: :has_many
    field :order_items, as: :has_many
    field :subscribers, as: :has_many
  end

  def filters
    filter Avo::Filters::CategoryFilter
    filter Avo::Filters::FeaturedFilter
  end

  def scopes
    scope :all, default: true
    scope :featured, -> { query.featured }
    scope :in_stock, -> { query.in_stock }
    scope :low_stock, -> { query.where('inventory_count < ?', 10) }
  end

  def actions
    action Avo::Actions::ToggleFeatured
    action Avo::Actions::UpdateInventory
  end
end
