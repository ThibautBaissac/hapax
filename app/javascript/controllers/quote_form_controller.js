import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="quote-form"
export default class QuoteFormController extends Controller {
  static targets = ["existingOption", "newOption", "existingSection", "newSection"]

  connect() {
    // Only initialize toggle if we have option targets (meaning there are existing quotes)
    if (this.hasExistingOptionTarget || this.hasNewOptionTarget) {
      this.toggleSections()
    }
  }

  toggle() {
    this.toggleSections()
  }

  toggleSections() {
    const existingOptionChecked = this.hasExistingOptionTarget && this.existingOptionTarget.checked
    const newOptionChecked = this.hasNewOptionTarget && this.newOptionTarget.checked

    // Show/hide existing section
    if (this.hasExistingSectionTarget) {
      this.existingSectionTarget.style.display = existingOptionChecked ? 'block' : 'none'
    }

    // Show/hide new section
    if (this.hasNewSectionTarget) {
      this.newSectionTarget.style.display = newOptionChecked ? 'block' : 'none'
    }
  }
}
