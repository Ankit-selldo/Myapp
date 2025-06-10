class SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token, only: [:create]
  # Remove custom authentication methods
  # skip_before_action :authenticate, only: [:new, :create]

  def new
    self.resource = resource_class.new(sign_in_params)
    store_location_for(resource, params[:redirect_to])
    super
  end
  
  

  def create
    super
  end

  def destroy
    super
  end

  protected

  def sign_in_params
    devise_parameter_sanitizer.sanitize(:sign_in)
  end
end
