class CreateMovementQuotes < ActiveRecord::Migration[8.1]
  def change
    create_table :movement_quotes do |t|
      t.references :quote, null: false, foreign_key: true
      t.references :movement, null: false, foreign_key: true
      t.string :category
      t.string :location_in_score
      t.string :excerpt_text
      t.text :notes

      t.timestamps
    end
  end
end
