class ApplicationMailer < ActionMailer::Base
  default from: 'genshemanipaljaipur@gmail.com'
  layout 'mailer'

  def self.smtp_settings
    {
      address: 'smtp.gmail.com',
      port: 587,
      domain: 'gmail.com',
      user_name: 'genshemanipaljaipur@gmail.com',
      password: 'qmcruroftnlxsphj',
      authentication: 'plain',
      enable_starttls_auto: true
    }
  end
end
