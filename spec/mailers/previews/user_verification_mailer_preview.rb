# Preview all emails at http://localhost:3000/rails/mailers/user_verification_mailer
class UserVerificationMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_verification_mailer/otp_email
  def otp_email
    UserVerificationMailer.otp_email
  end

end
