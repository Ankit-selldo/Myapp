class Avo::Resources::Order < Avo::BaseResource
  self.title = :number
  self.description = "Customer orders"
  self.search = {
    query: -> {
      query.ransack(
        id_eq: params[:q],
        number_cont: params[:q],
        shipping_name_cont: params[:q],
        email_cont: params[:q],
        m: 'or'
      ).result(distinct: false)
    }
  }
  self.visible_on_sidebar = true

  def fields
    field :id, as: :id
    field :number, as: :text, readonly: true
    field :status, as: :select, options: Order::STATUSES.transform_keys { |k| [k.to_s.humanize, k] }.to_h
    field :payment_status, as: :select, options: Order::PAYMENT_STATUSES.transform_keys { |k| [k.to_s.humanize, k] }.to_h
    field :payment_method, as: :select, options: Order::PAYMENT_METHODS
    field :total_amount, as: :number, format_using: -> { ActionController::Base.helpers.number_to_currency(value, unit: "₹", precision: 2) }
    field :discount_amount, as: :number, format_using: -> { ActionController::Base.helpers.number_to_currency(value, unit: "₹", precision: 2) }
    field :shipping_name, as: :text
    field :shipping_address, as: :text
    field :shipping_city, as: :text
    field :shipping_state, as: :text
    field :shipping_postal_code, as: :text
    field :shipping_country, as: :country
    field :phone, as: :text
    field :email, as: :text
    field :created_at, as: :date_time, readonly: true
    field :updated_at, as: :date_time, readonly: true

    field :user, as: :belongs_to
    field :coupon, as: :belongs_to
    field :order_items, as: :has_many
    field :products, as: :has_many, through: :order_items
  end

  def filters
    filter Avo::Filters::OrderStatusFilter
    filter Avo::Filters::PaymentStatusFilter
  end

  def scopes
    scope :all, default: true
    scope :pending, -> { query.pending }
    scope :processing, -> { query.where(status: :processing) }
    scope :shipped, -> { query.shipped }
    scope :delivered, -> { query.where(status: :delivered) }
    scope :cancelled, -> { query.cancelled }
  end

  def actions
    action Avo::Actions::UpdateOrderStatus
    action Avo::Actions::UpdatePaymentStatus
  end
end
