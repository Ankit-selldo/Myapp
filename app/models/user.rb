class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :blog_posts, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || password.present? }
  validates :name, presence: true
  validates :role, presence: true, inclusion: { in: %w[admin editor user] }

  before_validation :set_default_role, on: :create
  before_save :normalize_email

  scope :admins, -> { where(role: 'admin') }
  scope :editors, -> { where(role: 'editor') }
  scope :regular_users, -> { where(role: 'user') }

  def admin?
    role == 'admin'
  end

  def editor?
    role == 'editor'
  end

  def regular_user?
    role == 'user'
  end

  def generate_password_reset_token!
    update!(
      password_reset_token: generate_token,
      password_reset_sent_at: Time.current
    )
  end

  def password_reset_expired?
    password_reset_sent_at < 2.hours.ago
  end

  private

  def set_default_role
    self.role ||= 'user'
  end

  def normalize_email
    self.email_address = email_address.strip.downcase if email_address.present?
  end

  def generate_token
    SecureRandom.hex(20)
  end
end
