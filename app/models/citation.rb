class Citation < ApplicationRecord
  has_many :movement_citations, dependent: :destroy

  validates :title, presence: true
  validates :author, presence: true

  sanitizes :title, :author, tags: [], attributes: []
  sanitizes :notes
end
