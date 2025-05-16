class UserVerificationMailer < ApplicationMailer
  default from: 'genshemanipaljaipur@gmail.com'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_verification_mailer.otp_email.subject
  #
  def otp_email(user)
    begin
      @user = user
      @otp = user.otp
      @greeting = "Hi"
      
      Rails.logger.info "Preparing to send OTP email to #{@user.email}"
      
      mail(
        to: @user.email,
        subject: 'Verify your email address',
        template_name: 'otp_email'
      )
      
      Rails.logger.info "OTP email sent successfully to #{@user.email}"
    rescue StandardError => e
      Rails.logger.error "Failed to send OTP email: #{e.message}"
      raise e
    end
  end
end
