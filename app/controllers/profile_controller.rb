class ProfileController < ApplicationController
  before_action :set_user

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to(profile_path, notice: "Profile was successfully updated.")
    else
      render(:edit, status: :unprocessable_entity)
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.expect(user: [:firstname, :lastname, :phone, :address, :city, :zip_code, :bio])
  end
end
