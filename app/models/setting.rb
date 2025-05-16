class Setting < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  validates :value, presence: true

  # Categories for grouping settings
  CATEGORIES = %w[general theme notifications integrations payment shipping].freeze

  # Scopes
  scope :by_category, ->(category) { where("key LIKE ?", "#{category}_%") }

  class << self
    def get(key)
      setting = find_by(key: key)
      setting&.value
    end

    def set(key, value)
      setting = find_or_initialize_by(key: key)
      setting.update(value: value)
    end

    def get_all
      all.each_with_object({}) do |setting, hash|
        hash[setting.key] = get(setting.key)
      end
    end

    def update_theme(params)
      params.each do |key, value|
        set("theme_#{key}", value)
      end
      true
    rescue => e
      Rails.logger.error "Error updating theme settings: #{e.message}"
      false
    end
  end

  # Default settings
  DEFAULTS = {
    store_name: 'My Awesome Store',
    contact_email: 'contact@example.com',
    support_phone: '+1234567890',
    default_currency: 'INR',
    timezone: 'Asia/Kolkata',
    order_prefix: 'ORD',
    low_stock_threshold: 5,
    enable_customer_reviews: true,
    enable_guest_checkout: true,
    enable_wishlist: true,
    enable_back_in_stock_notifications: true,
    social_links: {
      facebook: '',
      twitter: '',
      instagram: '',
      youtube: ''
    },
    payment_methods: ['card', 'upi', 'net_banking']
  }

  def self.load_defaults!
    DEFAULTS.each do |key, value|
      set(key, value) unless exists?(key: key)
    end
  end

  def category
    key.split('_').first if key.include?('_')
  end

  def display_name
    key.split('_').drop(1).join(' ').titleize
  end
end 