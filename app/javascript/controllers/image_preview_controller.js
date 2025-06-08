import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="image-preview"
export default class extends Controller {
  static targets = ["input", "preview"]

  connect() {
  }

  previewImages(event) {
    const input = event.target
    const previewContainer = this.previewTarget
    const newImagesContainer = document.getElementById('new-images-container')

    // Clear existing previews
    if (newImagesContainer) {
      newImagesContainer.innerHTML = ''
    }

    if (input.files && input.files.length > 0) {
      previewContainer.classList.remove('hidden')

      Array.from(input.files).forEach((file, index) => {
        if (file.type.startsWith('image/')) {
          const reader = new FileReader()
          reader.onload = (e) => {
            const previewDiv = document.createElement('div')
            previewDiv.className = 'relative group'
            previewDiv.innerHTML = `
              <div class="aspect-square bg-gray-100 rounded-lg overflow-hidden">
                <img src="${e.target.result}" class="w-full h-full object-cover" alt="Preview">
              </div>
              <div class="absolute top-2 right-2 bg-black bg-opacity-50 text-white text-xs px-2 py-1 rounded">
                New
              </div>
            `
            if (newImagesContainer) {
              newImagesContainer.appendChild(previewDiv)
            }
          }
          reader.readAsDataURL(file)
        }
      })
    } else {
      previewContainer.classList.add('hidden')
    }
  }

  removeExistingImage(event) {
    const index = event.params.index
    const imageContainer = document.getElementById(`existing_image_${index}`)
    const keepField = document.getElementById(`keep_image_${index}`)

    if (imageContainer && keepField) {
      // Hide the image container
      imageContainer.style.display = 'none'
      // Remove the keep field so the image will be deleted
      keepField.remove()
    }
  }

  removeImage(event) {
    // Legacy method for backward compatibility
    const index = event.params.index
    const keepField = document.getElementById(`keep_image_${index}`)

    if (keepField) {
      // Hide the image container first
      const imageContainer = keepField.closest('.relative')
      if (imageContainer) {
        imageContainer.style.display = 'none'
      }
      // Remove the field entirely from the DOM so it's not submitted
      keepField.remove()
    }
  }
}
