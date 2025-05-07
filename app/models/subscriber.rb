class Subscriber < ApplicationRecord
  belongs_to :product

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :unsubscribe_token, presence: true, uniqueness: true

  before_validation :generate_unsubscribe_token, on: :create

  private

  def generate_unsubscribe_token
    self.unsubscribe_token = SecureRandom.hex(10)
  end
end
