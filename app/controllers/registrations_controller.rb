class RegistrationsController < Devise::RegistrationsController
  # Remove custom authentication methods
  # skip_before_action :authenticate, only: [:new, :create, :verify_email, :verify, :resend_otp]

  def new
    super
  end

  def create
    super
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
end      

