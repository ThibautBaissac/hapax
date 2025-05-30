class Composer < ApplicationRecord
  has_one_attached :portrait

  has_many :works, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true

  sanitizes :first_name, :last_name, :nationnality, tags: [], attributes: []
  sanitizes :short_bio, :bio

  def full_name
    [ first_name, last_name ].compact.join(" ").presence
  end
end
