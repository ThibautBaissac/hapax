class Composer < ApplicationRecord
  has_one_attached :portrait

  belongs_to :nationality
  has_many :works, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true

  sanitizes :first_name, :last_name, tags: [], attributes: []
  sanitizes :short_bio, :bio

  def full_name
    [ first_name, last_name ].compact.join(" ").presence
  end

  def quotes
    Quote.joins(:quote_details)
         .where(quote_details: { detailable: [works, works.joins(:movements).select("movements.*")].flatten })
         .distinct
  end
end
