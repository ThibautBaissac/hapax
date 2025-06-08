class Movement < ApplicationRecord
  belongs_to :work

  has_many :quote_details, as: :detailable, dependent: :destroy
  has_many :quotes, through: :quote_details

  validates :title, presence: true

  sanitizes :title, tags: [], attributes: []
  sanitizes :description
end
