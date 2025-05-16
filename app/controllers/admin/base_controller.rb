module Admin
  class BaseController < ActionController::Base
    before_action :authenticate
    before_action :require_admin
    layout 'admin'

    include Authentication  # Include any necessary modules
    protect_from_forgery with: :exception

    private

    def require_admin
      unless current_user&.admin?
        flash[:alert] = "You are not authorized to access this area."
        redirect_to root_path
      end
    end

    def authenticate
      unless current_user
        flash[:alert] = "Please log in to access this area."
        redirect_to login_path
      end
    end
  end
end 