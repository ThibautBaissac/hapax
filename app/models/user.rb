class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # ::lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable

  sanitizes :firstname, :lastname, :bio, :phone, :address, :city, :zip_code, tags: [], attributes: []

  def full_name
    [ firstname, lastname ].compact.join(" ").presence
  end
end
