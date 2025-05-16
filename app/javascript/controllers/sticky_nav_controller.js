import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.handleScroll = this.handleScroll.bind(this)
    window.addEventListener('scroll', this.handleScroll)
  }

  disconnect() {
    window.removeEventListener('scroll', this.handleScroll)
  }

  handleScroll() {
    const scrollPosition = window.scrollY
    if (scrollPosition > 100) {
      this.element.classList.add('is-sticky')
    } else {
      this.element.classList.remove('is-sticky')
    }
  }
} 