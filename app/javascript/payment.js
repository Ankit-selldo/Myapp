document.addEventListener('DOMContentLoaded', function() {
  const stripe = Stripe(document.querySelector('meta[name="stripe-key"]').content);
  const elements = stripe.elements();
  
  const card = elements.create('card', {
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
  });

  card.mount('#card-element');

  card.addEventListener('change', function(event) {
    const displayError = document.getElementById('card-errors');
    if (event.error) {
      displayError.textContent = event.error.message;
    } else {
      displayError.textContent = '';
    }
  });

  const form = document.querySelector('form');
  const submitButton = document.getElementById('submit-button');

  form.addEventListener('submit', async function(event) {
    event.preventDefault();
    submitButton.disabled = true;
    submitButton.textContent = 'Processing...';

    try {
      const response = await fetch(form.dataset.paymentIntentUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        }
      });

      const data = await response.json();

      if (data.error) {
        throw new Error(data.error);
      }

      const result = await stripe.confirmCardPayment(data.client_secret, {
        payment_method: {
          card: card,
          billing_details: {
            email: form.dataset.userEmail
          }
        }
      });

      if (result.error) {
        throw new Error(result.error.message);
      }

      const paymentIntentInput = document.createElement('input');
      paymentIntentInput.type = 'hidden';
      paymentIntentInput.name = 'payment_intent_id';
      paymentIntentInput.value = result.paymentIntent.id;
      form.appendChild(paymentIntentInput);
      
      form.submit();
    } catch (error) {
      const errorElement = document.getElementById('card-errors');
      errorElement.textContent = error.message;
      submitButton.disabled = false;
      submitButton.textContent = submitButton.dataset.originalText;
    }
  });
}); 