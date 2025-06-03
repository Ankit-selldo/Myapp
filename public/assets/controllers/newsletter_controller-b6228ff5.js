import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["email", "message"]

  connect() {
    console.log("Newsletter controller connected")
  }

  handleResponse(event) {
    console.log("Handling response:", event.detail)
    const [response] = event.detail.fetchResponse.response.json
    
    if (event.detail.success) {
      console.log("Subscription successful:", response)
      this.showMessage(response.message || 'Successfully subscribed! Please check your email.', 'success')
      this.emailTarget.value = ''
    } else {
      console.log("Subscription failed:", response)
      this.showMessage(response.errors?.join(', ') || 'Subscription failed. Please try again.', 'error')
    }
  }

  showMessage(text, type) {
    console.log("Showing message:", { text, type })
    if (this.hasMessageTarget) {
      this.messageTarget.textContent = text
      this.messageTarget.className = `message message--${type}`
      
      // Clear message after 5 seconds
      setTimeout(() => {
        this.messageTarget.textContent = ''
        this.messageTarget.className = 'message'
      }, 5000)
    }
  }
} 