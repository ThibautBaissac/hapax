class Work < ApplicationRecord
  belongs_to :composer

  has_many :movements, dependent: :destroy

  validates :title, presence: true

  sanitizes :title, :opus, tags: [], attributes: []
  sanitizes :description

  enum :form, {
    piece: 0,
    fugue: 1,
    cantata: 2,
    opera: 3,
    oratorio: 4,
    mass: 5,
    suite: 6,
    symphony: 7,
    sonata: 8,
    trio: 9,
    quartet: 10,
    quintet: 11,
    sextet: 12,
    septet: 13,
    concerto: 14,
    song_cycle: 15,
    prelude: 16,
    etude: 17,
    nocturne: 18,
    lieder: 19,
    ballade: 20,
    variation: 21
  }, default: :piece

  enum :structure, {
    movement: 0,
    melody: 1,
    lied: 2,
    act: 3,
    scene: 4
  }, default: :movement

  def title_with_composer
    if composer.present?
      "#{title} (#{composer.first_name} #{composer.last_name})"
    else
      title
    end
  end
end
