class BlogPost < ApplicationRecord
  belongs_to :author, class_name: 'User'
  has_rich_text :content
  has_one_attached :featured_image

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: %w[draft published archived] }
  validates :content, presence: true

  before_validation :generate_slug, on: :create
  before_save :normalize_title

  scope :published, -> { where(status: 'published') }
  scope :drafts, -> { where(status: 'draft') }
  scope :archived, -> { where(status: 'archived') }
  scope :recent, -> { order(created_at: :desc) }

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

  private

  def generate_slug
    self.slug = title.parameterize if title.present? && slug.blank?
  end

  def normalize_title
    self.title = title.strip if title.present?
  end
end
