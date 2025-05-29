import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="navbar"
export default class extends Controller {
  static targets = ["mobileMenu", "menuIcon", "closeIcon", "menuButton"]

  connect() {
    // Close mobile menu when clicking outside
    this.boundCloseOnOutsideClick = this.closeOnOutsideClick.bind(this)
    document.addEventListener('click', this.boundCloseOnOutsideClick)
  }

  disconnect() {
    // Clean up event listener when controller is disconnected
    document.removeEventListener('click', this.boundCloseOnOutsideClick)
  }

  toggleMenu() {
    const isOpen = !this.mobileMenuTarget.classList.contains('hidden')

    if (isOpen) {
      this.closeMenu()
    } else {
      this.openMenu()
    }
  }

  openMenu() {
    this.mobileMenuTarget.classList.remove('hidden')
    this.menuIconTarget.classList.add('hidden')
    this.closeIconTarget.classList.remove('hidden')
    this.menuButtonTarget.setAttribute('aria-expanded', 'true')
  }

  closeMenu() {
    this.mobileMenuTarget.classList.add('hidden')
    this.menuIconTarget.classList.remove('hidden')
    this.closeIconTarget.classList.add('hidden')
    this.menuButtonTarget.setAttribute('aria-expanded', 'false')
  }

  closeOnOutsideClick(event) {
    // Check if the click is outside both the mobile menu and the menu button
    if (this.mobileMenuTarget &&
        !this.mobileMenuTarget.contains(event.target) &&
        !this.menuButtonTarget.contains(event.target)) {
      this.closeMenu()
    }
  }

  // Close menu when a mobile menu link is clicked (for better UX)
  closeMobileMenu() {
    this.closeMenu()
  }
}
