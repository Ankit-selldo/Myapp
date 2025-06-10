class UserMailer < ApplicationMailer
  default from: 'from@example.com'

  def password_reset(user)
    @user = user
    @reset_url = edit_password_url(@user.password_reset_token)
    
    mail(
      to: @user.email_address,
      subject: "Reset your password"
    )
  end

  def verification_email(user)
    @user = user
    @otp = user.otp
    mail(
      to: @user.email,
      subject: 'Verify your email address'
    )
  end
end 