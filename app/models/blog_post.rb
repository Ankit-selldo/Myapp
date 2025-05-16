class BlogPost < ApplicationRecord
  belongs_to :author, class_name: 'User'
  has_rich_text :content
  has_one_attached :featured_image

  CATEGORIES = [
    'Style Guide',
    'Sustainability',
    'Lookbook',
    'Fashion Tips',
    'Trends'
  ].freeze

  ADDITIONAL_CATEGORIES = [
    'Behind the Scenes',
    'Designer Spotlight',
    'Care Instructions',
    'Size Guide',
    'Customer Stories'
  ].freeze

  validates :title, presence: true, length: { minimum: 5, maximum: 100 }
  validates :slug, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: %w[draft published archived] }
  validates :content, presence: true
  validates :category, presence: true, inclusion: { in: CATEGORIES + ADDITIONAL_CATEGORIES }
  validates :meta_title, presence: true, length: { maximum: 60 }
  validates :meta_description, presence: true, length: { maximum: 160 }

  before_validation :generate_slug, on: :create
  before_save :normalize_title
  before_save :set_published_at, if: :status_changed_to_published?
  before_save :calculate_reading_time

  scope :published, -> { where(status: 'published') }
  scope :drafts, -> { where(status: 'draft') }
  scope :archived, -> { where(status: 'archived') }
  scope :featured, -> { where(featured: true).published }
  scope :not_featured, -> { where(featured: false).or(where(featured: nil)) }
  scope :by_category, ->(category) { where(category: category) }
  scope :recent, -> { order(Arel.sql('COALESCE(published_at, created_at) DESC')) }

  def self.search(query)
    if query.present?
      where('title ILIKE :query OR content ILIKE :query', query: "%#{query}%")
    else
      all
    end
  end

  def self.filter_by_category(category)
    if category.present?
      where(category: category)
    else
      all
    end
  end

  def to_param
    slug
  end

  def published?
    status == 'published'
  end

  def draft?
    status == 'draft'
  end

  def archived?
    status == 'archived'
  end

  def related_products
    return [] if related_product_ids.blank?
    Product.where(id: related_product_ids)
  end

  def related_posts
    BlogPost.published
           .where(category: category)
           .where.not(id: id)
           .order(created_at: :desc)
  end

  def meta_title_with_fallback
    meta_title.presence || title
  end

  def meta_description_with_fallback
    meta_description.presence || ActionController::Base.helpers.strip_tags(content.to_s).truncate(160)
  end

  private

  def generate_slug
    self.slug = title.parameterize if title.present? && slug.blank?
  end

  def normalize_title
    self.title = title.strip if title.present?
    self.meta_title ||= title if title.present?
  end

  def status_changed_to_published?
    status_changed? && status == 'published'
  end

  def set_published_at
    self.published_at ||= Time.current if status == 'published'
  end

  def calculate_reading_time
    return if content.blank?
    
    words_per_minute = 200
    word_count = content.to_plain_text.split.size
    self.reading_time = (word_count.to_f / words_per_minute).ceil
  end
end
