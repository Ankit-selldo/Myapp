class Product < ApplicationRecord
  include Notifications
  has_many :subscribers, dependent: :destroy
  has_many :sub_products, dependent: :destroy
  has_one_attached :featured_image
  has_many_attached :images
  has_rich_text :description
  validates :name, presence: true
  validates :inventory_count, numericality: { greater_than_or_equal_to: 0 }

  after_update :notify_subscribers, if: :saved_change_to_inventory_count?

  private

  def notify_subscribers
    return unless inventory_count_previously_was == 0 && inventory_count.positive?

    subscribers.find_each do |subscriber|
      ProductMailer.with(product: self, subscriber: subscriber).in_stock.deliver_later
    end
  end
end
