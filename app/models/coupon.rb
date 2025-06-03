class Coupon < ApplicationRecord
  has_many :orders, class_name: 'Order', foreign_key: 'coupon_id'

  enum :discount_type, { fixed_amount: 0, percentage: 1 }

  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :discount_amount, presence: true, numericality: { greater_than: 0 }
  validates :minimum_order_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :usage_limit, numericality: { greater_than: 0 }, allow_nil: true
  validates :used_count, numericality: { greater_than_or_equal_to: 0 }
  validate :expires_at_after_starts_at
  validate :valid_percentage_amount

  before_save :upcase_code

  scope :active, -> { where(active: true) }
  scope :valid_at, ->(time = Time.current) {
    where('starts_at IS NULL OR starts_at <= ?', time)
    .where('expires_at IS NULL OR expires_at >= ?', time)
  }
  scope :available, -> { active.valid_at.where('usage_limit IS NULL OR used_count < usage_limit') }

  def available?
    active? && valid_period? && under_usage_limit?
  end

  def valid_for_order?(order_amount)
    return false unless available?
    return true if minimum_order_amount.nil?
    order_amount >= minimum_order_amount
  end

  def calculate_discount(order_amount)
    return 0 unless valid_for_order?(order_amount)

    if percentage?
      (order_amount * discount_amount / 100).round(2)
    else
      [discount_amount, order_amount].min
    end
  end

  def increment_usage!
    increment!(:used_count)
  end

  private

  def expires_at_after_starts_at
    return if starts_at.nil? || expires_at.nil?
    
    if expires_at < starts_at
      errors.add(:expires_at, "must be after starts at")
    end
  end

  def valid_percentage_amount
    return unless percentage?
    
    if discount_amount.present? && discount_amount > 100
      errors.add(:discount_amount, "cannot be greater than 100%")
    end
  end

  def valid_period?
    current_time = Time.current
    (starts_at.nil? || starts_at <= current_time) &&
      (expires_at.nil? || expires_at >= current_time)
  end

  def under_usage_limit?
    usage_limit.nil? || used_count < usage_limit
  end

  def upcase_code
    self.code = code.upcase if code.present?
  end
end 