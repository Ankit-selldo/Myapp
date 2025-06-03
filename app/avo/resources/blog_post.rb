class Avo::Resources::BlogPost < Avo::BaseResource
  self.title = :title
  self.description = "Blog posts and articles"
  self.search = {
    query: -> {
      query.ransack(
        title_cont: params[:q],
        category_cont: params[:q],
        m: 'or'
      ).result(distinct: false)
    }
  }
  self.visible_on_sidebar = true

  def find_record(id, pundit_user = nil)
    model_class.find_by(slug: id)
  end

  def fields
    field :id, as: :id
    field :title, as: :text, required: true
    field :slug, as: :text, readonly: true
    field :status, as: :select, options: { draft: "draft", published: "published", archived: "archived" }, default: "draft"
    field :category, as: :select, options: (BlogPost::CATEGORIES + BlogPost::ADDITIONAL_CATEGORIES).map { |c| [c, c] }.to_h
    field :featured, as: :boolean
    field :featured_image, as: :file, is_image: true, direct_upload: true, accept: "image/*"
    field :content, as: :trix
    field :meta_title, as: :text
    field :meta_description, as: :textarea
    field :reading_time, as: :number, readonly: true
    field :published_at, as: :date_time
    field :created_at, as: :date_time, readonly: true
    field :updated_at, as: :date_time, readonly: true

    field :author, as: :belongs_to, name: :author, class_name: "User"
    field :related_products, as: :has_many, name: "Related Products", use_resource: Avo::Resources::Product, many_to_many: true, model: Product do
      authorize_with { current_user.admin? }

      collection do
        @record.related_products
      end
    end
  end

  def filters
    filter Avo::Filters::BlogPostStatusFilter
    filter Avo::Filters::BlogPostCategoryFilter
  end

  def scopes
    scope :all, default: true
    scope :published, -> { query.published }
    scope :drafts, -> { query.drafts }
    scope :archived, -> { query.archived }
    scope :featured, -> { query.featured }
  end

  def actions
    action Avo::Actions::PublishPost
    action Avo::Actions::ArchivePost
    action Avo::Actions::ToggleFeatured
  end
end
