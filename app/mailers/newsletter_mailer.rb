class NewsletterMailer < ApplicationMailer
  def welcome_email(subscriber)
    @subscriber = subscriber
    @unsubscribe_url = unsubscribe_newsletter_url(token: @subscriber.unsubscribe_token)
    
    mail(
      to: @subscriber.email,
      subject: "Welcome to Our Fashion Community! ��"
    )
  end
end 