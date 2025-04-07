import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pwa"
export default class extends Controller {
  static targets = ["button"]

  installPrompt = null

  connect() {
    // Bind event handlers to maintain 'this' context
    this.beforeInstallPrompt = this.beforeInstallPrompt.bind(this)
    this.appInstalled = this.appInstalled.bind(this)

    // Listen for the beforeinstallprompt event
    window.addEventListener("beforeinstallprompt", this.beforeInstallPrompt)

    // Listen for the appinstalled event
    window.addEventListener("appinstalled", this.appInstalled)
  }

  disconnect() {
    // Clean up event listeners when the controller is disconnected
    window.removeEventListener("beforeinstallprompt", this.beforeInstallPrompt)
    window.removeEventListener("appinstalled", this.appInstalled)
  }

  beforeInstallPrompt(event) {
    // Prevent the mini-infobar from appearing on mobile
    event.preventDefault()

    // Stash the event so it can be triggered later.
    this.installPrompt = event

    // Update UI to notify the user they can install the PWA
    this.buttonTarget.hidden = false
  }

  async promptInstall() {
    if (!this.installPrompt) {
      return
    }

    // Show the install prompt
    this.installPrompt.prompt()

    // Wait for the user to respond to the prompt
    const { outcome } = await this.installPrompt.userChoice
    console.log(`Install prompt was: ${outcome}`)

    // Reset the install prompt variable
    this.disableInstallPrompt()
  }

  appInstalled() {
    console.log("PWA was installed")
    this.disableInstallPrompt()
  }

  disableInstallPrompt() {
    this.installPrompt = null
    this.buttonTarget.hidden = true
  }
}
