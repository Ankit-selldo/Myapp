class Avo::Resources::Subscriber < Avo::BaseResource
  self.title = :email
  self.description = "Email subscribers for products and updates."
  self.search = {
    query: -> do
      query.ransack(id_eq: params[:q], email_cont: params[:q], m: "or").result(distinct: false)
    end
  }
  self.visible_on_sidebar = true
  
  def fields
    field :id, as: :id
    field :email, as: :text, required: true
    field :created_at, as: :date_time, readonly: true
    field :updated_at, as: :date_time, readonly: true

    field :product, as: :belongs_to
  end

  def scopes
    scope :all, default: true
  end
end
