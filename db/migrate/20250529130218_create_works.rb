class CreateWorks < ActiveRecord::Migration[8.1]
  def change
    create_table :works do |t|
      t.string :opus
      t.string :title, null: false
      t.text :description
      t.integer :duration
      t.references :composer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
