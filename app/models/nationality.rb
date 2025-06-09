class Nationality < ApplicationRecord
  has_many :composers

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true

  scope :ordered, -> { order(:code) }
end
