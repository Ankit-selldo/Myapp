class Avo::Resources::User < Avo::BaseResource
  self.title = :name
  self.description = "Users of the application"
  self.search = {
    query: -> {
      query.ransack(
        name_cont: params[:q],
        email_cont: params[:q],
        m: 'or'
      ).result(distinct: false)
    }
  }
  self.visible_on_sidebar = true

  def fields
    field :id, as: :id
    field :name, as: :text, required: true
    field :email, as: :text, required: true, format_using: -> { value.downcase }
    field :role, as: :select, options: { customer: "Customer", admin: "Admin" }
    field :phone, as: :text
    field :avatar, as: :file, is_image: true, hide_on: [:index]
    field :email_verified_at, as: :date_time, hide_on: [:index]
    field :created_at, as: :date_time, readonly: true
    field :updated_at, as: :date_time, readonly: true

    field :orders, as: :has_many
    field :products, as: :has_many
    field :blog_posts, as: :has_many
    field :cart, as: :has_one
  end

  def filters
    filter Avo::Filters::RoleFilter
  end

  def scopes
    scope :all, default: true
    scope :admins, -> { query.admins }
    scope :customers, -> { query.where(role: :customer) }
  end

  def actions
    action Avo::Actions::VerifyEmail
    action Avo::Actions::SendPasswordReset
  end
end
