class PasswordMailer < ApplicationMailer
  def reset
    @user = params[:user]
    @token = params[:token]
    @url = edit_password_url(@token)

    mail(
      to: @user.email_address,
      subject: "Reset your password"
    )
  end
end 