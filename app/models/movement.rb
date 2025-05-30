class Movement < ApplicationRecord
  belongs_to :work

  has_many :movement_quotes, dependent: :destroy
  has_many :quotes, through: :movement_quotes

  validates :title, presence: true

  sanitizes :title, tags: [], attributes: []
  sanitizes :description
end
