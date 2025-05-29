import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flash"
export default class extends Controller {
  static targets = ["progressBar"]
  static values = {
    autoDismiss: Boolean,
    delay: { type: Number, default: 5000 }
  }

  connect() {
    // Animate the flash message in
    this.animateIn()

    // Start auto-dismiss if enabled
    if (this.autoDismissValue) {
      this.startAutoDismiss()
    }
  }

  disconnect() {
    // Clean up any running timers
    if (this.dismissTimer) {
      clearTimeout(this.dismissTimer)
    }
    if (this.progressTimer) {
      clearInterval(this.progressTimer)
    }
  }

  animateIn() {
    // Small delay to ensure the element is rendered
    setTimeout(() => {
      this.element.classList.remove('translate-x-full', 'opacity-0')
      this.element.classList.add('translate-x-0', 'opacity-100')
    }, 100)
  }

  animateOut() {
    this.element.classList.remove('translate-x-0', 'opacity-100')
    this.element.classList.add('translate-x-full', 'opacity-0')

    // Remove the element after animation completes
    setTimeout(() => {
      if (this.element.parentNode) {
        this.element.remove()
      }
    }, 500)
  }

  dismiss() {
    this.animateOut()
  }

  startAutoDismiss() {
    if (this.hasProgressBarTarget) {
      this.animateProgressBar()
    }

    this.dismissTimer = setTimeout(() => {
      this.dismiss()
    }, this.delayValue)
  }

  animateProgressBar() {
    const progressBar = this.progressBarTarget
    const duration = this.delayValue
    const steps = 100
    const stepDuration = duration / steps
    let currentStep = 0

    progressBar.style.width = '100%'

    this.progressTimer = setInterval(() => {
      currentStep++
      const progress = ((steps - currentStep) / steps) * 100
      progressBar.style.width = `${progress}%`

      if (currentStep >= steps) {
        clearInterval(this.progressTimer)
      }
    }, stepDuration)
  }

  // Pause auto-dismiss on hover
  pauseAutoDismiss() {
    if (this.dismissTimer) {
      clearTimeout(this.dismissTimer)
    }
    if (this.progressTimer) {
      clearInterval(this.progressTimer)
    }
  }

  // Resume auto-dismiss on mouse leave
  resumeAutoDismiss() {
    if (this.autoDismissValue) {
      // Calculate remaining time based on progress bar width
      const progressBar = this.progressBarTarget
      const currentWidth = parseFloat(progressBar.style.width) || 100
      const remainingTime = (currentWidth / 100) * this.delayValue

      if (remainingTime > 0) {
        this.dismissTimer = setTimeout(() => {
          this.dismiss()
        }, remainingTime)

        // Resume progress bar animation
        this.resumeProgressBar(remainingTime, currentWidth)
      }
    }
  }

  resumeProgressBar(remainingTime, currentWidth) {
    const progressBar = this.progressBarTarget
    const steps = Math.floor(currentWidth)
    const stepDuration = remainingTime / steps
    let currentStep = 0

    this.progressTimer = setInterval(() => {
      currentStep++
      const progress = currentWidth - ((currentStep / steps) * currentWidth)
      progressBar.style.width = `${progress}%`

      if (currentStep >= steps) {
        clearInterval(this.progressTimer)
      }
    }, stepDuration)
  }
}
