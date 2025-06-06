class Nationality < ApplicationRecord
  has_many :composers, dependent: :nullify

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true

  scope :ordered, -> { order(:code) }

  def to_s
    name
  end
end
