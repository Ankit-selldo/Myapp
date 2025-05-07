require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  config.require_master_key = true

  # Enable static file serving from the `/public` folder
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=\#{1.year.to_i}"
  }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  config.asset_host = ENV['ASSET_HOST'] if ENV['ASSET_HOST'].present?

  # Specifies the header that your server uses for sending files.
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = ENV.fetch('STORAGE_SERVICE', 'local').to_sym

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true
  config.ssl_options = { hsts: { subdomains: true, preload: true, expires: 1.year } }

  # Include generic and useful information about system operation, but avoid logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII).
  config.log_level = ENV.fetch('RAILS_LOG_LEVEL', 'info').to_sym

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Use a different cache store in production.
  config.cache_store = :redis_cache_store, {
    url: ENV['REDIS_URL'],
    error_handler: -> (method:, returning:, exception:) {
      Sentry.capture_exception(exception, level: 'warning',
        tags: { method: method, returning: returning }
      )
    }
  }

  # Use a real queuing backend for Active Job (and separate queues per environment).
  config.active_job.queue_adapter = :sidekiq
  config.active_job.queue_name_prefix = "\#{Rails.env}_default"

  # Email configuration
  config.action_mailer.perform_caching = false
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = { host: ENV.fetch('APP_HOST') }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: ENV.fetch('SMTP_HOST'),
    port: ENV.fetch('SMTP_PORT', 587),
    domain: ENV.fetch('SMTP_DOMAIN'),
    user_name: ENV.fetch('SMTP_USERNAME'),
    password: ENV.fetch('SMTP_PASSWORD'),
    authentication: :plain,
    enable_starttls_auto: true
  }

  # Enable locale fallbacks for I18n.
  config.i18n.fallbacks = true

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Enable DNS rebinding protection and other Host header attacks.
  config.hosts = [ENV.fetch('APP_HOST')]

  # Log to STDOUT by default
  config.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  
  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Enable rack-timeout
  config.middleware.insert_before Rack::Runtime, Rack::Timeout, service_timeout: ENV.fetch('RACK_TIMEOUT', 15).to_i
end
