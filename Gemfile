source "https://rubygems.org"

ruby "3.4.3"

# Rails core
gem "rails", "~> 8.0.2"
gem "propshaft"
gem "puma"
gem "pg"
gem "redis"
gem "bootsnap", require: false

# Background processing
gem "sidekiq"
gem "sidekiq-scheduler"
gem "good_job"

# Error monitoring
gem "sentry-ruby"
gem "sentry-rails"

# Authentication & Security
gem "bcrypt"
gem "devise"
gem "rack-timeout"

# Storage and uploads
gem "aws-sdk-s3", require: false
gem "image_processing"

# Frontend
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"

# Monitoring and logging
gem "amazing_print"

# Analytics
gem 'groupdate', '~> 6.4'  # For time-based grouping
gem 'chartkick', '~> 5.0'  # For charts and graphs

group :development, :test do
  gem "debug"
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "dotenv-rails"
end

group :development do
  gem "web-console"
  gem "error_highlight"
  gem "letter_opener"
  gem "brakeman"
  gem "bundler-audit"
  gem "rubocop-rails"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
  gem "simplecov"
end

gem "tailwindcss-rails", "~> 4.2"

# Pagination
gem "kaminari"
