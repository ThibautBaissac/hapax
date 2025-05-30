class Quote < ApplicationRecord
  has_many :movement_quotes, dependent: :destroy

  validates :title, presence: true
  validates :author, presence: true

  sanitizes :title, :author, tags: [], attributes: []
  sanitizes :notes
end
