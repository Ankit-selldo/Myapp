class ApplicationController < ActionController::Base
  # Include Devise
  include Devise::Controllers::Helpers
  
  # Remove custom authentication includes
  # include Authentication
  include Authorization
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Add authenticate_user! here, but with a condition to skip for certain controllers
  before_action :authenticate_user!, unless: -> { devise_controller? || is_a?(HomeController) || is_a?(PwaController) }

  before_action :configure_permitted_parameters, if: :devise_controller?
  around_action :switch_locale
  before_action :set_cart
  before_action :set_newsletter_subscription
  before_action :set_blog_subscription
  before_action :log_params_for_debugging

  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::ParameterMissing, with: :bad_request
  rescue_from ActionController::InvalidAuthenticityToken, with: :unprocessable_entity

  def switch_locale(&action)
    # Temporarily hardcode the locale to isolate the issue
    locale = I18n.default_locale
    Rails.logger.info "[DEBUG] Using hardcoded locale: #{locale}"
    
    I18n.with_locale(locale, &action)
  end

  private

  def configure_permitted_parameters
    # Flatten the keys in case they're nested arrays
    sign_up_keys = [:first_name, :last_name, :phone, :address, :city, :state, :country, :postal_code, :avatar].flatten
    account_update_keys = [:first_name, :last_name, :phone, :address, :city, :state, :country, :postal_code, :avatar].flatten
    
    devise_parameter_sanitizer.permit(:sign_up, keys: sign_up_keys)
    devise_parameter_sanitizer.permit(:account_update, keys: account_update_keys)
  rescue => e
    Rails.logger.error "[configure_permitted_parameters] Error: #{e.message}"
    Rails.logger.error "[configure_permitted_parameters] Keys class: #{sign_up_keys.class}" if defined?(sign_up_keys)
    Rails.logger.error "[configure_permitted_parameters] Backtrace: #{e.backtrace.first(5).join("\n")}"
  end

  def set_cart
    @cart = current_cart
  end 

  def current_cart
    if user_signed_in?
      current_user.cart || current_user.create_cart
    else
      # Use session.id.to_s to ensure we have a string
      Cart.find_or_create_by(session_id: session.id.to_s)
    end
  end

  def set_newsletter_subscription
    @newsletter_subscription = NewsletterSubscriber.new
  end

  def set_blog_subscription
    @blog_subscription = NewsletterSubscriber.new
  end

  def log_params_for_debugging
    Rails.logger.info "[PARAMS DEBUG] params.class: \\#{params.class}, params: \\#{params.inspect}"
    if params[:user]
      Rails.logger.info "[PARAMS DEBUG] params[:user].class: \\#{params[:user].class}, params[:user]: \\#{params[:user].inspect}"
    end
  end

  def not_found
    respond_to do |format|
      format.html { render file: Rails.root.join('public/404.html'), status: :not_found }
      format.json { render json: { error: 'Not found' }, status: :not_found }
    end
  end

  def bad_request(exception)
    respond_to do |format|
      format.html { render file: Rails.root.join('public/400.html'), status: :bad_request }
      format.json { render json: { error: 'Bad request' }, status: :bad_request }
    end
  end

  def unprocessable_entity
    respond_to do |format|
      format.html { render file: Rails.root.join('public/422.html'), status: :unprocessable_entity }
      format.json { render json: { error: 'Unprocessable entity' }, status: :unprocessable_entity }
    end
  end

  def server_error
    respond_to do |format|
      format.html { render file: Rails.root.join('public/500.html'), status: :internal_server_error }
      format.json { render json: { error: 'Internal server error' }, status: :internal_server_error }
    end
  end
end