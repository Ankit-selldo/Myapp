class RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # Remove custom authentication methods
  # skip_before_action :authenticate, only: [:new, :create, :verify_email, :verify, :resend_otp]

  def new
    super
  end

  def create
    super do |user|
      if user.persisted?
        user.generate_otp!
        # Send verification email
        UserMailer.verification_email(user).deliver_later
      end
    end
  end

  def edit
    super
  end

  def update
    super
  end

  def destroy
    super
  end

  def verify_email
    # This action will render the email verification form
  end

  def verify
    user = User.find_by(otp: params[:otp])
    if user&.otp_valid?
      user.verify_email!
      sign_in(user)
      redirect_to root_path, notice: 'Email verified successfully!'
    else
      flash.now[:alert] = 'Invalid or expired OTP'
      render :verify_email
    end
  end

  def resend_otp
    user = User.find_by(email: params[:email])
    if user
      user.generate_otp!
      UserMailer.verification_email(user).deliver_later
      redirect_to verify_email_path, notice: 'OTP has been resent to your email'
    else
      redirect_to verify_email_path, alert: 'User not found'
    end
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :phone])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :phone])
  end

  def after_sign_up_path_for(resource)
    verify_email_path
  end
end      

