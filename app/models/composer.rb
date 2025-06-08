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
    # Get quotes directly from composer's works
    work_quote_ids = works.joins(:quotes).pluck('quotes.id')

    # Get quotes from movements belonging to composer's works
    movement_quote_ids = Quote.joins(:quote_details)
                              .joins("INNER JOIN movements ON quote_details.detailable_id = movements.id")
                              .where(quote_details: { detailable_type: 'Movement' })
                              .where(movements: { work_id: works.select(:id) })
                              .pluck(:id)

    # Return distinct quotes from both sources
    Quote.where(id: (work_quote_ids + movement_quote_ids).uniq)
  end
end
