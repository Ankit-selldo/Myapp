import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]

  connect() {
    // Show the first tab by default
    if (window.location.hash) {
      this.switchToHash()
    } else {
      this.switchTab(this.tabTargets[0])
    }
  }

  switch(event) {
    event.preventDefault()
    this.switchTab(event.currentTarget)
  }

  switchToHash() {
    const hash = window.location.hash.slice(1)
    const tab = this.tabTargets.find(t => t.dataset.category === hash)
    if (tab) this.switchTab(tab)
  }

  switchTab(tab) {
    this.tabTargets.forEach(t => {
      t.classList.remove("border-blue-500", "text-blue-600")
      t.classList.add("border-transparent", "text-gray-500", "hover:text-gray-700", "hover:border-gray-300")
    })

    tab.classList.remove("border-transparent", "text-gray-500", "hover:text-gray-700", "hover:border-gray-300")
    tab.classList.add("border-blue-500", "text-blue-600")

    const category = tab.dataset.category
    this.panelTargets.forEach(p => {
      p.classList.toggle("hidden", p.id !== category)
    })

    // Update URL hash without scrolling
    history.pushState(null, null, `#${category}`)
  }
} 