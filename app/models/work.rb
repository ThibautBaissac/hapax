class Work < ApplicationRecord
  belongs_to :composer

  has_many :movements, dependent: :destroy
  has_many :quote_details, as: :detailable, dependent: :destroy
  has_many :quotes, through: :quote_details

  validates :title, presence: true
  validate :cannot_have_both_movements_and_quotes

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
    variation: 21,
    paraphrase: 22,
    melody: 23,
  }, default: :piece

  enum :structure, {
    movement: 0,
    melodies: 1,
    lied: 2,
    act: 3,
    scene: 4
  }, default: :movement

  def can_add_quotes?
    movements.empty?
  end

  def display_quotes?
    movements.empty? && quote_details.any?
  end

  def display_movements?
    movements.any?
  end

  private

  def cannot_have_both_movements_and_quotes
    if movements.any? && quote_details.any?
      errors.add(:base, "A work cannot have both movements and quotes")
    end
  end
end
