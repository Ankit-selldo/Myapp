import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.updateColor()
  }

  increment() {
    const currentValue = parseInt(this.inputTarget.value) || 0
    this.inputTarget.value = currentValue + 1
    this.update()
  }

  decrement() {
    const currentValue = parseInt(this.inputTarget.value) || 0
    if (currentValue > 0) {
      this.inputTarget.value = currentValue - 1
      this.update()
    }
  }

  update() {
    this.updateColor()
    this.element.requestSubmit()
  }

  updateColor() {
    const value = parseInt(this.inputTarget.value) || 0
    if (value < 10) {
      this.inputTarget.classList.add('text-red-600')
      this.inputTarget.classList.remove('text-gray-900')
    } else {
      this.inputTarget.classList.add('text-gray-900')
      this.inputTarget.classList.remove('text-red-600')
    }
  }
} 