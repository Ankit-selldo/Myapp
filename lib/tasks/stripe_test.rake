namespace :stripe do
  desc "Test Stripe integration"
  task test: :environment do
    require 'stripe'
    
    puts "\n=== Testing Stripe Integration ===\n\n"
    
    # Test 1: Check API Key Configuration
    puts "Test 1: Checking API Key Configuration..."
    if Stripe.api_key.present?
      puts "✅ Stripe API key is configured"
    else
      puts "❌ Stripe API key is missing"
      exit 1
    end
    
    # Test 2: Check Publishable Key Configuration
    puts "\nTest 2: Checking Publishable Key Configuration..."
    if Rails.configuration.stripe[:publishable_key].present?
      puts "✅ Stripe publishable key is configured"
    else
      puts "❌ Stripe publishable key is missing"
      exit 1
    end
    
    # Test 3: Test API Connection
    puts "\nTest 3: Testing API Connection..."
    begin
      balance = Stripe::Balance.retrieve
      puts "✅ Successfully connected to Stripe API"
      puts "   Available balance: #{balance.available.first.amount / 100.0} #{balance.available.first.currency}"
    rescue Stripe::AuthenticationError => e
      puts "❌ Stripe authentication failed: #{e.message}"
      exit 1
    rescue Stripe::APIError => e
      puts "❌ Stripe API error: #{e.message}"
      exit 1
    end
    
    # Test 4: Create Test Payment Intent
    puts "\nTest 4: Creating Test Payment Intent..."
    begin
      # Convert INR to AED (using the same rate as in the controller)
      inr_amount = 1000 # ₹1000.00
      aed_amount = (inr_amount / 22.5).round(2) # Convert to AED
      stripe_amount = (aed_amount * 100).to_i # Convert to fils

      payment_intent = Stripe::PaymentIntent.create(
        amount: stripe_amount,
        currency: 'aed',
        payment_method_types: ['card'],
        metadata: {
          test: true,
          original_amount_in_inr: inr_amount
        }
      )
      
      puts "✅ Successfully created payment intent"
      puts "   Original Amount (INR): ₹#{inr_amount}"
      puts "   Converted Amount (AED): د.إ#{aed_amount}"
      puts "   Payment Intent ID: #{payment_intent.id}"
      puts "   Client Secret: #{payment_intent.client_secret}"
      
      # Clean up the test payment intent
      Stripe::PaymentIntent.cancel(payment_intent.id)
      puts "   Test payment intent cancelled"
    rescue Stripe::StripeError => e
      puts "❌ Failed to create payment intent: #{e.message}"
      exit 1
    end
    
    # Test 5: Create Test Customer
    puts "\nTest 5: Creating Test Customer..."
    begin
      customer = Stripe::Customer.create(
        email: 'test@example.com',
        name: 'Test Customer',
        metadata: {
          test: true
        }
      )
      
      puts "✅ Successfully created test customer"
      puts "   Customer ID: #{customer.id}"
      
      # Clean up the test customer
      Stripe::Customer.delete(customer.id)
      puts "   Test customer deleted"
    rescue Stripe::StripeError => e
      puts "❌ Failed to create test customer: #{e.message}"
      exit 1
    end
    
    puts "\n=== All Tests Passed! ===\n"
    puts "Your Stripe integration is working correctly."
    puts "You can now proceed with implementing the payment flow in your application."
  end
end 