module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate
    helper_method :current_user, :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :authenticate, **options
    end
  end

  private

  def authenticate
    unless authenticated?
      store_location
      redirect_to login_path, alert: "Please log in first."
    end
  end

  def login(user)
    reset_session
    session[:user_id] = user.id
    Current.user = user
  end

  def logout
    Current.user = nil
    reset_session
  end

  def store_location
    session[:return_to] = request.fullpath if request.get?
  end

  def redirect_back_or_to(default, **options)
    redirect_to(session.delete(:return_to) || default, **options)
  end

  def authenticated?
    current_user.present? && session[:user_id].present?
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def require_authentication
    resume_session || request_authentication
  end

  def resume_session
    Current.session ||= find_session_by_cookie
  end

  def find_session_by_cookie
    Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
  end

  def request_authentication
    session[:return_to_after_authenticating] = request.url
    redirect_to new_session_path
  end

  def after_authentication_url
    session.delete(:return_to_after_authenticating) || root_url
  end

  def start_new_session_for(user)
    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
      Current.session = session
      cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
    end
  end

  def terminate_session
    Current.session.destroy
    cookies.delete(:session_id)
  end
end
