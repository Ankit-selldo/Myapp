class SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token, only: [:create]
  # Remove custom authentication methods
  # skip_before_action :authenticate, only: [:new, :create]

  def new
    @resource = User.new
    render :new
  end
  
  

  def create
    super
  end

  def destroy
    super
  end
end
