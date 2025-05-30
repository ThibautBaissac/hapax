class CreateQuotes < ActiveRecord::Migration[8.1]
  def change
    create_table :quotes do |t|
      t.string :title, null: false
      t.string :author, null: false
      t.text :notes

      t.timestamps
    end
  end
end
