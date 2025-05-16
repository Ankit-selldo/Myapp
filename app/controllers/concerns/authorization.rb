module Authorization
  extend ActiveSupport::Concern

  included do
    helper_method :admin?, :editor?, :regular_user?
  end

  private

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "You are not authorized to perform this action."
    end
  end

  def require_editor_or_admin
    unless current_user&.admin? || current_user&.editor?
      redirect_to root_path, alert: "You are not authorized to perform this action."
    end
  end

  def admin?
    current_user&.admin?
  end

  def editor?
    current_user&.editor?
  end

  def regular_user?
    current_user&.regular_user?
  end
end 