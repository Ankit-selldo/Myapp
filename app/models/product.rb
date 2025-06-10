class Product < ApplicationRecord
  
  include ProductImageProcessable
  
  belongs_to :user
  has_many :subscribers, dependent: :destroy
  has_many :product_variants, dependent: :destroy
  has_rich_text :description
  has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_fill: [56, 56]
    attachable.variant :medium, resize_to_fill: [200, 200]
  end
  has_many_attached :images

  has_many :order_items
  has_many :orders, through: :order_items

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :category, presence: true
  validates :inventory_count, numericality: { greater_than_or_equal_to: 0 }

  scope :featured, -> { where(featured: true) }
  scope :latest, -> { order(created_at: :desc) }
  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :in_stock, -> { where('inventory_count > 0') }
  scope :search, ->(query) {
    return all unless query.present?

    left_joins(:rich_text_description)
      .where(
        "products.name ILIKE :query OR products.description ILIKE :query OR action_text_rich_texts.body ILIKE :query",
        query: "%#{query}%"
      )
      .distinct
  }

  CATEGORIES = {
    'hoodies' => { 
      name: 'Hoodies',
      sizes: ['XS', 'S', 'M', 'L', 'XL', 'XXL'],
      colors: ['Black', 'Grey', 'Navy', 'White', 'Brown']
    },
    'tshirts' => {
      name: 'T-Shirts',
      sizes: ['XS', 'S', 'M', 'L', 'XL', 'XXL'],
      colors: ['White', 'Black', 'Grey', 'Navy', 'Red']
    },
    'shirts' => {
      name: 'Shirts',
      sizes: ['XS', 'S', 'M', 'L', 'XL', 'XXL'],
      colors: ['White', 'Blue', 'Light Blue', 'Pink', 'Black']
    },
    'jeans' => {
      name: 'Jeans',
      sizes: ['28', '30', '32', '34', '36', '38'],
      colors: ['Blue', 'Black', 'Grey', 'Dark Blue']
    },
    'shorts' => {
      name: 'Shorts',
      sizes: ['XS', 'S', 'M', 'L', 'XL'],
      colors: ['Black', 'Grey', 'Navy', 'Khaki']
    },
    'caps' => {
      name: 'Caps',
      sizes: ['One Size'],
      colors: ['Black', 'White', 'Navy', 'Red', 'Grey']
    },
    'sweaters' => {
      name: 'Sweaters',
      sizes: ['XS', 'S', 'M', 'L', 'XL', 'XXL'],
      colors: ['Grey', 'Navy', 'Black', 'Burgundy']
    },
    'jackets' => {
      name: 'Jackets',
      sizes: ['XS', 'S', 'M', 'L', 'XL', 'XXL'],
      colors: ['Black', 'Brown', 'Navy', 'Olive', 'Red']
    }
  }

  after_create_commit :process_image
  after_update_commit :process_image, if: :will_process_image?
  after_update :notify_subscribers, if: :saved_change_to_inventory_count?

  def formatted_price
    ActionController::Base.helpers.number_to_currency(price, unit: "₹", precision: 2)
  end

  def available_sizes
    CATEGORIES.dig(category, :sizes) || []
  end

  def available_colors
    CATEGORIES.dig(category, :colors) || []
  end

  def category_name
    CATEGORIES.dig(category, :name) || category.titleize
  end

  def variants_by_color
    product_variants.group_by(&:color)
  end

  def variants_matrix
    matrix = {}
    available_colors.each do |color|
      matrix[color] = {}
      available_sizes.each do |size|
        matrix[color][size] = product_variants.find_by(color: color, size: size)
      end
    end
    matrix
  end

  def in_stock?
    product_variants.any? { |variant| variant.available_stock.positive? }
  end

  def variant_in_stock?(color, size)
    variant = product_variants.find_by(color: color, size: size)
    variant&.available_stock.to_i.positive?
  end

  def available_stock(color, size)
    variant = product_variants.find_by(color: color, size: size)
    variant&.available_stock.to_i
  end

  def update_inventory_count
    # Update the total inventory count based on variants and their available stock
    total = product_variants.sum(&:available_stock)
    update_column(:inventory_count, total) if inventory_count != total
  end

  private

  def will_process_image?
    image.attached? && attachment_changes['image'].present?
  end

  def notify_subscribers
    return unless inventory_count_previously_was == 0 && inventory_count.positive?

    subscribers.find_each do |subscriber|
      ProductMailer.with(product: self, subscriber: subscriber).in_stock.deliver_later
    end
  end
end
