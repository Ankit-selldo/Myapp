class Payment < ApplicationRecord
  belongs_to :order
  belongs_to :user

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_id, presence: true
  validates :status, presence: true

  enum status: {
    pending: 'pending',
    completed: 'completed',
    failed: 'failed'
  }

  def self.create_from_stripe(payment_intent, **options)
    order = options[:order]
    user = options[:user]

    raise ArgumentError, "Order is required" unless order
    raise ArgumentError, "User is required" unless user

    create!(
      order: order,
      user: user,
      amount: payment_intent.amount / 100.0, # Convert from cents to dollars
      payment_id: payment_intent.id,
      status: payment_intent.status == 'succeeded' ? 'completed' : 'failed',
      payment_details: payment_intent.to_json
    )
  end
end 