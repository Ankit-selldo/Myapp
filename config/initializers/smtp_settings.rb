if Rails.env.development? || Rails.env.production?
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    address: 'smtp.gmail.com',
    port: 587,
    domain: 'gmail.com',
    user_name: 'genshemanipaljaipur@gmail.com',
    password: ENV['GMAIL_APP_PASSWORD'],
    authentication: 'plain',
    enable_starttls_auto: true
  }
end 