class Movement < ApplicationRecord
  belongs_to :work

  has_many :movement_citations, dependent: :destroy
  has_many :citations, through: :movement_citations

  validates :title, presence: true

  sanitizes :title, tags: [], attributes: []
  sanitizes :description
end
