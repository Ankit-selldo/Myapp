class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_fill: [40, 40]
    attachable.variant :medium, resize_to_fill: [100, 100]
  end

  has_one :cart, dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :blog_posts, dependent: :destroy
  has_many :orders

  validates :name, presence: true
  validates :email, 
            presence: true, 
            uniqueness: { case_sensitive: false },
            format: { 
              with: /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/,
              message: "must be a valid email address (e.g., user@example.com)"
            },
            length: { maximum: 255 }
  validates :phone, format: { with: /\A\d{10}\z/, message: "must be a 10-digit number" }, allow_blank: true

  enum :role, { customer: 0, admin: 1 }, default: :customer

  before_save :normalize_email
  before_create :generate_verification_token

  scope :admins, -> { where(role: :admin) }
  scope :editors, -> { where(role: :editor) }
  scope :regular_users, -> { where(role: :user) }

  # Build address from user's profile information
  def build_address_from_profile
    {
      shipping_name: name,
      shipping_address: address,
      shipping_city: city,
      shipping_state: state,
      shipping_postal_code: postal_code,
      shipping_country: country,
      phone: phone,
      email: email
    }
  end

  # Override Devise's find_first_by_auth_conditions method
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if (email = conditions.delete(:email))
      where(conditions).where(["lower(email) = :value", { value: email.downcase }]).first
    elsif conditions[:email].nil?
      where(conditions).first
    else
      where(conditions).first
    end
  end

  def admin?
    role == "admin"
  end

  def editor?
    role.to_sym == :editor
  end

  def regular_user?
    role.to_sym == :user
  end

  def generate_password_reset_token!
    send_reset_password_instructions
  end

  def password_reset_expired?
    reset_password_sent_at < 2.hours.ago
  end

  def generate_otp!
    self.otp = SecureRandom.random_number(100000..999999).to_s
    self.otp_sent_at = Time.current
    save!(validate: false)
    Rails.logger.info "Generated OTP for user #{id}: #{otp}"
  end

  def otp_valid?
    return false unless otp_sent_at.present?
    time_elapsed = Time.current - otp_sent_at
    is_valid = time_elapsed <= 10.minutes
    Rails.logger.info "OTP validation for user #{id}: elapsed time #{time_elapsed.to_i}s, valid: #{is_valid}"
    is_valid
  end

  def verify_email!
    update!(
      email_verified_at: Time.current,
      otp: nil,
      otp_sent_at: nil
    )
    Rails.logger.info "Email verified for user #{id}"
  end

  def verified?
    email_verified_at.present?
  end

  protected

  # Override Devise's email required validation
  def email_required?
    false # We use email instead
  end

  # Override Devise's email changed notification
  def email_changed?
    email_changed?
  end

  # Override Devise's reconfirmation required check
  def reconfirmation_required?
    false
  end

  # Override Devise's email dirtyness check
  def postpone_email_change?
    false
  end

  private

  def normalize_email
    self.email = email.strip.downcase if email.present?
  end

  def generate_verification_token
    self.verification_token = SecureRandom.urlsafe_base64
  end
end
