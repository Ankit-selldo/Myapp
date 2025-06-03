class PasswordsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create, :edit, :update]

  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user
      user.generate_password_reset_token!
      UserMailer.password_reset(user).deliver_later
      redirect_to login_path, notice: "Password reset instructions have been sent to your email."
    else
      flash.now[:alert] = "Email address not found"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find_by!(password_reset_token: params[:id])
    if @user.password_reset_expired?
      redirect_to new_password_path, alert: "Password reset link has expired. Please try again."
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to new_password_path, alert: "Invalid password reset token"
  end

  def update
    @user = User.find_by!(password_reset_token: params[:id])
    
    if @user.password_reset_expired?
      redirect_to new_password_path, alert: "Password reset link has expired. Please try again."
    elsif @user.update(password_params)
      @user.update!(password_reset_token: nil, password_reset_sent_at: nil)
      redirect_to login_path, notice: "Password has been reset successfully. Please log in."
    else
      render :edit, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to new_password_path, alert: "Invalid password reset token"
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
