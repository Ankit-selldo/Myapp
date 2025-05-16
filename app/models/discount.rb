class Discount < ApplicationRecord
  has_and_belongs_to_many :products

  validates :code, presence: true, uniqueness: true
  validates :discount_type, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :minimum_purchase, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :starts_at, presence: true
  validates :expires_at, presence: true
  validate :expires_at_must_be_after_starts_at

  enum :discount_type, { percentage: 0, fixed_amount: 1 }

  scope :active, -> { where(active: true) }
  scope :valid_now, -> { where('starts_at <= ? AND expires_at >= ?', Time.current, Time.current) }
  scope :expired, -> { where('expires_at < ?', Time.current) }
  scope :upcoming, -> { where('starts_at > ?', Time.current) }

  def currently_valid?
    active? && Time.current.between?(starts_at, expires_at)
  end

  def calculate_discount(amount)
    return 0 unless currently_valid?
    return 0 if minimum_purchase.present? && amount < minimum_purchase

    if percentage?
      (amount * self.amount / 100).round(2)
    else
      [self.amount, amount].min
    end
  end

  private

  def expires_at_must_be_after_starts_at
    return if expires_at.blank? || starts_at.blank?

    if expires_at < starts_at
      errors.add(:expires_at, "must be after the start date")
    end
  end
end 