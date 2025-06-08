class Quote < ApplicationRecord
  has_many_attached :images
  has_many :quote_details, dependent: :destroy
  has_many :works,     through: :quote_details, source: :detailable, source_type: "Work"
  has_many :movements, through: :quote_details, source: :detailable, source_type: "Movement"

  validates :title, presence: true
  validates :author, presence: true
  validate :acceptable_images

  sanitizes :title, :author, tags: [], attributes: []
  sanitizes :notes

  def title_with_author
    "#{title} (by #{author})"
  end

  private

  def acceptable_images
    return unless images.attached?

    images.each do |image|
      unless image.blob.byte_size <= 10.megabytes
        errors.add(:images, "Image #{image.filename} is too large (maximum is 10MB)")
      end

      acceptable_types = ["image/jpeg", "image/jpg", "image/png", "image/gif"]
      unless acceptable_types.include?(image.blob.content_type)
        errors.add(:images, "Image #{image.filename} must be a JPEG, PNG, or GIF")
      end
    end
  end
end
