class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :line_items, dependent: :destroy
  has_many :products, through: :line_items

  validates :session_id, presence: true, if: -> { user_id.nil? }

  def total_price
    line_items.sum(&:total_price)
  end

  def total_items
    line_items.sum(&:quantity)
  end
end 