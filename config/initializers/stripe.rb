require 'stripe'

# Configure Stripe with your API keys from Rails credentials
Rails.configuration.stripe = {
  publishable_key: Rails.application.credentials.dig(:stripe, :publishable_key),
  secret_key: Rails.application.credentials.dig(:stripe, :secret_key)
}

# Set the API key for server-side usage
Stripe.api_key = Rails.configuration.stripe[:secret_key]

# Log Stripe configuration
Rails.logger.info "Stripe API Version: #{Stripe.api_version}"
Rails.logger.info "Stripe API Key configured: #{Stripe.api_key.present?}"
Rails.logger.info "Stripe Publishable Key configured: #{Rails.configuration.stripe[:publishable_key].present?}"

# Configure Stripe logging
Stripe.log_level = 'debug'
