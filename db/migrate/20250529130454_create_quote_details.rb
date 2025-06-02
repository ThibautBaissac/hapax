class CreateQuoteDetails < ActiveRecord::Migration[8.1]
  def change
    create_table :quote_details do |t|
      t.references :quote, null: false, foreign_key: true
      t.references :detailable, polymorphic: true, null: false, index: true

      t.string :category
      t.string :location
      t.string :excerpt_text
      t.text :notes

      t.timestamps
    end
  end
end
