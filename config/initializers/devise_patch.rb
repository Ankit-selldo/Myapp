module Devise
  module Models
    module Validatable
      def email_required?
        false
      end

      def email_changed?
        false
      end

      def will_save_change_to_email?
        false
      end
    end
  end
end

# Patch Devise parameter sanitizer to handle email
Devise::ParameterSanitizer.class_eval do
  private

  def sign_up
    default_params.permit(auth_keys + [:password, :password_confirmation, :name] + [:remember_me])
  end

  def sign_in
    default_params.permit(auth_keys + [:password, :remember_me])
  end

  def account_update
    default_params.permit(auth_keys + [:password, :password_confirmation, :current_password])
  end

  def default_params
    @default_params ||= begin
      params = %i(password password_confirmation)
      params.push(:email, :remember_me)
      params
    end
  end
end 