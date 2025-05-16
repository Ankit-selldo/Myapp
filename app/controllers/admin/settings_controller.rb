module Admin
  class SettingsController < BaseController
    def index
      @settings = Setting.all.group_by(&:category)
    end

    def update
      settings_params.each do |key, value|
        setting = Setting.find_or_initialize_by(key: key)
        setting.update(value: value)
      end

      flash[:notice] = "Settings updated successfully"
      redirect_to admin_settings_path
    end

    def update_theme
      settings_params[:theme].each do |key, value|
        setting = Setting.find_or_initialize_by(key: "theme_#{key}")
        setting.update(value: value)
      end

      flash[:notice] = "Theme settings updated successfully"
      redirect_to admin_settings_path(anchor: 'theme')
    end

    def update_notifications
      settings_params[:notifications].each do |key, value|
        setting = Setting.find_or_initialize_by(key: "notification_#{key}")
        setting.update(value: value)
      end

      flash[:notice] = "Notification settings updated successfully"
      redirect_to admin_settings_path(anchor: 'notifications')
    end

    def update_integrations
      settings_params[:integrations].each do |key, value|
        setting = Setting.find_or_initialize_by(key: "integration_#{key}")
        setting.update(value: value)
      end

      flash[:notice] = "Integration settings updated successfully"
      redirect_to admin_settings_path(anchor: 'integrations')
    end

    private

    def settings_params
      params.require(:settings).permit!
    end
  end
end 