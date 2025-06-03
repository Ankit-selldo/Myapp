import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]
  
  connect() {
    this.timeout = null
  }

  debounce(event) {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    this.timeout = setTimeout(() => {
      this.performSearch(event.target.value)
    }, 300)
  }

  performSearch(query) {
    const form = this.element
    const searchParams = new URLSearchParams(window.location.search)
    searchParams.set("search", query)
    
    const url = `${form.action}?${searchParams.toString()}`
    
    fetch(url, {
      headers: {
        "Accept": "text/vnd.turbo-stream.html"
      }
    })
    .then(response => response.text())
    .then(html => {
      Turbo.renderStreamMessage(html)
    })
  }
} 