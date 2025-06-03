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

# REMOVE ALL PATCHES TO Devise::ParameterSanitizer
# If you need to customize permitted parameters, do it in ApplicationController#configure_permitted_parameters only.

 