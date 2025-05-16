class NewsletterSubscriber < ApplicationRecord
  validates :email, presence: true, 
                   uniqueness: { case_sensitive: false },
                   format: { with: URI::MailTo::EMAIL_REGEXP }

  has_secure_token :unsubscribe_token

  before_save :normalize_email
  after_create :send_welcome_email

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end

  def send_welcome_email
    NewsletterMailer.welcome_email(self).deliver_later
  end
end 