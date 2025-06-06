class CreateNationalities < ActiveRecord::Migration[8.1]
  def change
    create_table :nationalities do |t|
      t.string :name, null: false
      t.string :code, null: false

      t.timestamps
    end

    add_index :nationalities, :name, unique: true
    add_index :nationalities, :code, unique: true
  end
end
