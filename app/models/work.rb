class Work < ApplicationRecord
  belongs_to :composer

  has_many :movements, dependent: :destroy

  validates :title, presence: true

  sanitizes :title, :opus, tags: [], attributes: []
  sanitizes :description

  def title_with_composer
    if composer.present?
      "#{title} (#{composer.first_name} #{composer.last_name})"
    else
      title
    end
  end
end
