class AddNationalityToComposers < ActiveRecord::Migration[8.1]
  def change
    remove_column :composers, :nationality
    add_reference :composers, :nationality, foreign_key: true
  end
end
