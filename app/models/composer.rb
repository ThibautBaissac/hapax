class Composer < ApplicationRecord
  has_many :works, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true

  def full_name
    [ first_name, last_name ].compact.join(" ").presence
  end
end
