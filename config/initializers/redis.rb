require 'redis'

$redis = Redis.new(
  url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1'),
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
)

# Log Redis connection
Rails.logger.info "Connected to Redis at #{ENV.fetch('REDIS_URL', 'redis://localhost:6379/1')}"

# Test connection
begin
  $redis.ping
rescue Redis::CannotConnectError => error
  Rails.logger.error "Failed to connect to Redis: #{error.message}"
end 