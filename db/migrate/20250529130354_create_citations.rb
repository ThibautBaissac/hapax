class CreateCitations < ActiveRecord::Migration[8.1]
  def change
    create_table :citations do |t|
      t.string :title, null: false
      t.string :author, null: false
      t.text :notes

      t.timestamps
    end
  end
end
