class CreateComposers < ActiveRecord::Migration[8.1]
  def change
    create_table :composers do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.date :birth_date
      t.date :death_date
      t.text :short_bio
      t.text :bio
      t.string :nationality

      t.timestamps
    end
  end
end
