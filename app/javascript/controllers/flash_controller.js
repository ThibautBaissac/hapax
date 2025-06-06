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
    if (!this.hasProgressBarTarget) {
      console.log('Flash Controller: No progress bar target found')
      return
    }

    const progressBar = this.progressBarTarget
    const duration = this.delayValue
    const steps = 100
    const stepDuration = duration / steps
    let currentStep = 0

    console.log('Flash Controller: Starting progress bar animation', {
      duration,
      steps,
      stepDuration
    })

    // Clear any existing timer
    if (this.progressTimer) {
      clearInterval(this.progressTimer)
    }

    progressBar.style.width = '100%'
    console.log('Flash Controller: Initial width set to 100%')

    this.progressTimer = setInterval(() => {
      currentStep++
      const progress = ((steps - currentStep) / steps) * 100
      progressBar.style.width = `${Math.max(progress, 0)}%`

      // Log every 10 steps to avoid spam
      if (currentStep % 10 === 0) {
        console.log(`Flash Controller: Step ${currentStep}, Progress: ${progress}%`)
      }

      if (currentStep >= steps || progress <= 0) {
        console.log('Flash Controller: Progress bar animation completed')
        clearInterval(this.progressTimer)
      }
    }, stepDuration)
  }

  // Pause auto-dismiss on hover
  pauseAutoDismiss() {
    if (this.dismissTimer) {
      clearTimeout(this.dismissTimer)
      this.dismissTimer = null
    }
    if (this.progressTimer) {
      clearInterval(this.progressTimer)
      this.progressTimer = null
    }
  }

  // Resume auto-dismiss on mouse leave
  resumeAutoDismiss() {
    if (this.autoDismissValue && this.hasProgressBarTarget) {
      // Calculate remaining time based on progress bar width
      const progressBar = this.progressBarTarget
      const currentWidth = parseFloat(progressBar.style.width) || 100
      const remainingTime = (currentWidth / 100) * this.delayValue

      if (remainingTime > 100) { // Only resume if there's at least 100ms left
        this.dismissTimer = setTimeout(() => {
          this.dismiss()
        }, remainingTime)

        // Resume progress bar animation
        this.resumeProgressBar(remainingTime, currentWidth)
      } else {
        // If very little time left, just dismiss immediately
        this.dismiss()
      }
    }
  }

  resumeProgressBar(remainingTime, currentWidth) {
    const progressBar = this.progressBarTarget
    // Ensure we have at least 10 steps for smooth animation
    const steps = Math.max(Math.floor(currentWidth), 10)
    const stepDuration = remainingTime / steps
    let currentStep = 0

    this.progressTimer = setInterval(() => {
      currentStep++
      const progress = currentWidth - ((currentStep / steps) * currentWidth)
      progressBar.style.width = `${Math.max(progress, 0)}%`

      if (currentStep >= steps || progress <= 0) {
        clearInterval(this.progressTimer)
      }
    }, stepDuration)
  }
}
