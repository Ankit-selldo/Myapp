import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["code", "message"]

  connect() {
    console.log("Coupon controller connected")
  }

  checkEnter(event) {
    if (event.key === "Enter") {
      this.apply()
    }
  }

  async apply() {
    const code = this.codeTarget.value.trim()
    if (!code) {
      this.showMessage("Please enter a coupon code", "error")
      return
    }

    try {
      const response = await fetch('/coupons/apply', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ code })
      })

      const data = await response.json()

      if (response.ok) {
        this.showMessage(data.message, "success")
        // Update the order summary
        document.getElementById('order-summary').innerHTML = data.html
        // Reload the page after a short delay to show the applied coupon state
        setTimeout(() => { window.location.reload() }, 1000)
      } else {
        this.showMessage(data.error, "error")
      }
    } catch (error) {
      console.error('Error:', error)
      this.showMessage("An error occurred while applying the coupon", "error")
    }
  }

  async remove(event) {
    event.preventDefault()
    
    try {
      const response = await fetch('/coupons/remove', {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        }
      })

      const data = await response.json()

      if (response.ok) {
        // Update the order summary
        document.getElementById('order-summary').innerHTML = data.html
        // Reload the page to show the coupon removed state
        window.location.reload()
      } else {
        this.showMessage("Failed to remove coupon", "error")
      }
    } catch (error) {
      console.error('Error:', error)
      this.showMessage("An error occurred while removing the coupon", "error")
    }
  }

  showMessage(text, type) {
    const messageElement = this.messageTarget
    messageElement.textContent = text
    messageElement.className = `mt-2 text-sm ${type === 'error' ? 'text-red-600' : 'text-green-600'}`
  }
} 