import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "cardElement", "cardErrors", "submitButton"]
  static values = {
    publishableKey: String,
    orderId: String,
    amount: String
  }

  connect() {
    // Don't initialize Stripe here - do it only when needed
    this.setupPaymentMethodHandling()
  }

  setupPaymentMethodHandling() {
    const selectedPaymentMethod = document.querySelector('input[name="payment_method"]:checked')
    if (selectedPaymentMethod && selectedPaymentMethod.value === 'online') {
      this.initializeStripe()
    }
  }

  initializeStripe() {
    if (!this.stripe) {
      this.stripe = Stripe(this.publishableKeyValue)
      this.elements = this.stripe.elements()
      
      this.card = this.elements.create('card', {
        style: {
          base: {
            fontSize: '16px',
            color: '#32325d',
            fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif',
            '::placeholder': {
              color: '#aab7c4'
            }
          },
          invalid: {
            color: '#fa755a',
            iconColor: '#fa755a'
          }
        }
      })
      
      this.card.mount(this.cardElementTarget)
      this.card.addEventListener('change', this.handleCardChange.bind(this))
    }
  }

  async handleSubmit(event) {
    event.preventDefault()
    
    const selectedPaymentMethod = document.querySelector('input[name="payment_method"]:checked').value
    this.submitButtonTarget.disabled = true
    
    if (selectedPaymentMethod === 'cod') {
      // For COD, just submit the form directly
      this.submitButtonTarget.textContent = 'Processing...'
      this.formTarget.submit()
      return
    }
    
    // For online payment, create payment intent first
    this.submitButtonTarget.textContent = 'Processing payment...'
    
    try {
      // Initialize Stripe if not already initialized
      if (!this.stripe) {
        this.initializeStripe()
      }
      
      // Create payment intent
      const response = await fetch(`/orders/${this.orderIdValue}/create_payment_intent`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        }
      })
      
      const data = await response.json()
      
      if (data.error) {
        throw new Error(data.error)
      }
      
      // Confirm the payment
      const { paymentIntent, error } = await this.stripe.confirmCardPayment(data.client_secret, {
        payment_method: {
          card: this.card,
          billing_details: {
            name: document.querySelector('meta[name="user-name"]')?.content || '',
            email: document.querySelector('meta[name="user-email"]')?.content || ''
          }
        }
      })
      
      if (error) {
        throw new Error(error.message)
      }
      
      if (!paymentIntent) {
        throw new Error('Payment intent not created')
      }
      
      // Set the payment intent ID
      const paymentIntentIdField = this.formTarget.querySelector('#payment_intent_id')
      paymentIntentIdField.value = paymentIntent.id
      
      // Submit the form
      this.formTarget.submit()
      
    } catch (error) {
      this.cardErrorsTarget.textContent = error.message
      this.submitButtonTarget.disabled = false
      this.submitButtonTarget.textContent = `Pay ₹${this.amountValue}`
    }
  }
  
  handleCardChange(event) {
    if (event.error) {
      this.cardErrorsTarget.textContent = event.error.message
    } else {
      this.cardErrorsTarget.textContent = ''
    }
  }
} 