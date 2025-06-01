class CreateWorks < ActiveRecord::Migration[8.1]
  def change
    create_table :works do |t|
      t.string :opus
      t.string :title, null: false
      t.text :description
      t.integer :duration
      t.string :instrumentation
      t.boolean :recorded
      t.integer :form
      t.integer :structure
      t.date :start_date_composed
      t.date :end_date_composed
      t.boolean :unsure_start_date
      t.boolean :unsure_end_date
      t.references :composer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
