# Monkey-patch Array to prevent .permit errors in controllers and Devise
class Array
  def permit(*args)
    puts "[Array#permit PATCH] .permit called on Array! Returning empty ActionController::Parameters. Caller: \n#{caller.join("\n")}"
    ActionController::Parameters.new
  end
end

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MyApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Set the default locale
    config.i18n.default_locale = :en
    config.i18n.available_locales = [:en, :hi]

    # Configure error handling
    config.exceptions_app = self.routes
    
    # Use environment variable for secret_key_base
    config.secret_key_base = ENV['SECRET_KEY_BASE'] if ENV['SECRET_KEY_BASE']
  end
end
