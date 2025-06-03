import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    // Hide menu by default
    this.menuTarget.style.display = "none"
  }

  toggleMenu() {
    if (this.menuTarget.style.display === "none") {
      this.menuTarget.style.display = "flex"
      document.body.style.overflow = "hidden" // Prevent scrolling when menu is open
    } else {
      this.menuTarget.style.display = "none"
      document.body.style.overflow = "" // Restore scrolling
    }
  }

  // Close menu when clicking outside
  clickOutside(event) {
    if (!this.element.contains(event.target) && !this.menuTarget.classList.contains("hidden")) {
      this.closeMenu()
    }
  }
} 