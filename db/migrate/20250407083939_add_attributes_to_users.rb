class AddAttributesToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column(:users, :firstname, :string)
    add_column(:users, :lastname, :string)
    add_column(:users, :phone, :string)
    add_column(:users, :address, :string)
    add_column(:users, :city, :string)
    add_column(:users, :zip_code, :string)
  end
end
