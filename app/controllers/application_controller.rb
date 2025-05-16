class ApplicationController < ActionController::Base
  include Authentication
  include Authorization
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  around_action :switch_locale
  before_action :set_current_attributes

  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::ParameterMissing, with: :bad_request
  rescue_from ActionController::InvalidAuthenticityToken, with: :unprocessable_entity

  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  private

  def set_current_attributes
    Current.user = current_user
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
