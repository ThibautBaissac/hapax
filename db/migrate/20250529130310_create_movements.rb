class CreateMovements < ActiveRecord::Migration[8.1]
  def change
    create_table :movements do |t|
      t.string :title, null: false
      t.references :work, null: false, foreign_key: true
      t.integer :position, null: false
      t.integer :duration
      t.text :description

      t.timestamps
    end
  end
end
