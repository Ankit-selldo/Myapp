import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["couponCode", "applyButton", "removeButton", "message", "total", "discount"]

  connect() {
    this.applyButtonTarget.addEventListener("click", this.applyCoupon.bind(this))
    this.removeButtonTarget.addEventListener("click", this.removeCoupon.bind(this))
  }

  async applyCoupon(event) {
    event.preventDefault()
    const code = this.couponCodeTarget.value.trim()
    
    if (!code) {
      this.showMessage("Please enter a coupon code", "error")
      return
    }

    try {
      const response = await fetch(`/orders/${this.data.get("orderId")}/apply_coupon`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ coupon_code: code })
      })

      const data = await response.json()

      if (response.ok) {
        this.showMessage(data.message, "success")
        this.updateTotals(data)
        this.showRemoveButton()
      } else {
        this.showMessage(data.message, "error")
      }
    } catch (error) {
      this.showMessage("An error occurred. Please try again.", "error")
    }
  }

  async removeCoupon(event) {
    event.preventDefault()

    try {
      const response = await fetch(`/orders/${this.data.get("orderId")}/remove_coupon`, {
        method: "DELETE",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        }
      })

      const data = await response.json()

      if (response.ok) {
        this.showMessage(data.message, "success")
        this.updateTotals(data)
        this.hideRemoveButton()
        this.couponCodeTarget.value = ""
      } else {
        this.showMessage(data.message, "error")
      }
    } catch (error) {
      this.showMessage("An error occurred. Please try again.", "error")
    }
  }

  showMessage(message, type) {
    this.messageTarget.textContent = message
    this.messageTarget.className = `mt-2 text-sm ${type === "success" ? "text-green-600" : "text-red-600"}`
  }

  updateTotals(data) {
    if (this.hasTotalTarget) {
      this.totalTarget.textContent = `₹${data.total}`
    }
    if (this.hasDiscountTarget && data.discount) {
      this.discountTarget.textContent = `-₹${data.discount}`
    }
  }

  showRemoveButton() {
    this.removeButtonTarget.classList.remove("hidden")
    this.applyButtonTarget.classList.add("hidden")
  }

  hideRemoveButton() {
    this.removeButtonTarget.classList.add("hidden")
    this.applyButtonTarget.classList.remove("hidden")
  }
} 