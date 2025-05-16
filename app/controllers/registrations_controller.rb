class RegistrationsController < ApplicationController
  skip_before_action :authenticate, only: [:new, :create, :verify_email, :verify, :resend_otp]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    if @user.save
      Rails.logger.info "User created successfully with ID: #{@user.id}"
      
      @user.generate_otp!
      Rails.logger.info "Generated OTP for user #{@user.id}"
      
      begin
        UserVerificationMailer.otp_email(@user).deliver_now
        session[:unverified_user_id] = @user.id
        redirect_to verify_email_path, notice: "Please check your email for the verification code."
      rescue StandardError => e
        Rails.logger.error "Failed to send OTP email: #{e.message}"
        @user.destroy
        flash.now[:alert] = "Failed to send verification email. Please try again."
        render :new, status: :unprocessable_entity
      end
    else
      Rails.logger.error "User creation failed: #{@user.errors.full_messages.join(', ')}"
      render :new, status: :unprocessable_entity
    end
  end

  def verify_email
    @user = User.find_by(id: session[:unverified_user_id])
    
    unless @user
      redirect_to new_registration_path, alert: "Please sign up first."
      return
    end
    
    if @user.verified?
      redirect_to root_path, notice: "Your email is already verified."
    end
  end

  def verify
    @user = User.find_by(id: session[:unverified_user_id])
    
    unless @user
      Rails.logger.error "No unverified user found in session"
      redirect_to new_registration_path, alert: "Please sign up first."
      return
    end
    
    Rails.logger.info "Verifying OTP for user #{@user.id}. Submitted OTP: #{params[:otp]}, Stored OTP: #{@user.otp}"
    
    if @user.otp == params[:otp] && @user.otp_valid?
      Rails.logger.info "OTP verified successfully for user #{@user.id}"
      @user.verify_email!
      session.delete(:unverified_user_id)
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Email verified successfully! Welcome to our store!"
    else
      Rails.logger.error "Invalid OTP for user #{@user.id}. OTP expired? #{!@user.otp_valid?}"
      flash.now[:alert] = "Invalid or expired verification code."
      render :verify_email, status: :unprocessable_entity
    end
  end

  def resend_otp
    @user = User.find_by(id: session[:unverified_user_id])
    
    if @user && !@user.verified?
      @user.generate_otp!
      Rails.logger.info "Generated new OTP for user #{@user.id}: #{@user.otp}"
      
      UserVerificationMailer.otp_email(@user).deliver_now
      
      redirect_to verify_email_path, notice: "A new verification code has been sent to your email."
    else
      redirect_to new_registration_path, alert: "Please sign up first."
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end      

