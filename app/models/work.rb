class Work < ApplicationRecord
  belongs_to :composer

  has_many :movements, dependent: :destroy

  validates :title, presence: true

  def title_with_composer
    if composer.present?
      "#{title} (#{composer.first_name} #{composer.last_name})"
    else
      title
    end
  end
end
