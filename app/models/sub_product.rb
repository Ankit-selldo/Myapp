class SubProduct < ApplicationRecord
  belongs_to :product
  has_many_attached :images

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :color, presence: true
  validates :size, presence: true
end
