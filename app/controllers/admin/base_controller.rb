module Admin
  class BaseController < ActionController::Base
    before_action :authenticate_user!
    before_action :require_admin
    layout 'admin'

    protect_from_forgery with: :exception

    private

    def require_admin
      unless current_user&.admin?
        flash[:alert] = "You are not authorized to access this area."
        redirect_to root_path
      end
    end
  end
end 