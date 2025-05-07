begin
  require 'sidekiq'
  require 'sidekiq/web'

  Sidekiq.configure_server do |config|
    config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1') }

    config.error_handlers << Proc.new do |ex, ctx_hash|
      Sentry.capture_exception(ex, extra: ctx_hash) if defined?(Sentry)
    end
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1') }
  end

  # Configure Sidekiq-specific session middleware
  Sidekiq::Web.use ActionDispatch::Cookies
  Sidekiq::Web.use ActionDispatch::Session::CookieStore, key: "_interslice_session"

rescue LoadError
  # Sidekiq is not available
end 