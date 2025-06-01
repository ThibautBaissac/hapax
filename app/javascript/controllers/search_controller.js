import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "form"]

  connect() {
    // Auto-focus the search input when the page loads
    if (this.hasInputTarget && !this.inputTarget.value) {
      this.inputTarget.focus()
    }
  }

  // Submit form when Enter is pressed
  submitOnEnter(event) {
    if (event.key === "Enter") {
      event.preventDefault()
      this.formTarget.submit()
    }
  }

  // Clear search input
  clear() {
    this.inputTarget.value = ""
    this.inputTarget.focus()
  }

  // Handle search input focus
  focusInput() {
    this.inputTarget.select()
  }
}
