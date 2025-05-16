class SessionsController < ApplicationController
  skip_before_action :authenticate, only: [:new, :create]

  def new
    redirect_to root_path, notice: "You are already signed in." if authenticated?
  end

  def create
    user = User.find_by(email: params[:email]&.strip&.downcase)
    
    if user&.valid_password?(params[:password])
      Rails.logger.info "User authenticated successfully: #{user.email}"
      reset_session
      session[:user_id] = user.id
      Current.user = user
      
      redirect_to session[:return_to] || root_path, notice: "Welcome back, #{user.name}!"
      session.delete(:return_to)
    else
      Rails.logger.info "Failed login attempt for email: #{params[:email]}"
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    Rails.logger.info "User logged out: #{current_user&.email}"
    reset_session
    Current.user = nil
    redirect_to root_path, notice: "You have been logged out."
  end
end
