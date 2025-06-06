class Quote < ApplicationRecord
  has_many_attached :images
  has_many :quote_details, dependent: :destroy
  has_many :works,     through: :quote_details, source: :detailable, source_type: "Work"
  has_many :movements, through: :quote_details, source: :detailable, source_type: "Movement"

  validates :title, presence: true
  validates :author, presence: true
  # We run custom validations on each associated QuoteLocation (in that model),
  # but we also want to catch “cross‐location” conflicts here:
  validate :no_conflicting_locations
  validate :acceptable_images

  sanitizes :title, :author, tags: [], attributes: []
  sanitizes :notes

  private

  #
  # If a Quote already has a location on Work W, we cannot also
  # have a location on any Movement whose work_id == W.id, and vice versa.
  #
  def no_conflicting_locations
    # 1) If there is at least one work‐location for Work W:
    quoted_work_ids   = quote_details.where(detailable_type: "Work").pluck(:detailable_id).uniq
    # 2) If there is at least one movement‐location, find its parent work IDs:
    quoted_mv_parent_ids = quote_details
                            .where(detailable_type: "Movement")
                            .includes(:detailable)  # eager‐load the Movement
                            .map { |ql| ql.detailable.work_id }
                            .uniq

    # If a work W is both in quoted_work_ids and quoted_mv_parent_ids → conflict
    overlap = quoted_work_ids & quoted_mv_parent_ids
    if overlap.any?
      overlap.each do |w_id|
        errors.add(
          :base,
          "Quote cannot be tied at the work level (Work ##{w_id}) AND also at a movement under that same work."
        )
      end
    end
  end

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
