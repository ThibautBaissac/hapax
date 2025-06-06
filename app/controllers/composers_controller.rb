class ComposersController < ApplicationController
  before_action :set_composer, only: %i[ show edit update destroy ]

  def index
    @pagy, @composers = pagy(Composer.includes(:nationality), items: 12)
  end

  def show
  end

  def new
    @composer = Composer.new
    @nationalities = Nationality.ordered
  end

  def edit
    @nationalities = Nationality.ordered
  end

  def create
    @composer = Composer.new(composer_params)

    respond_to do |format|
      if @composer.save
        format.html { redirect_to(@composer, notice: "Composer was successfully created.") }
      else
        format.html { render(:new, status: :unprocessable_entity) }
      end
    end
  end

  def update
    respond_to do |format|
      if @composer.update(composer_params)
        format.html { redirect_to(@composer, notice: "Composer was successfully updated.") }
      else
        format.html { render(:edit, status: :unprocessable_entity) }
      end
    end
  end

  def destroy
    @composer.destroy!

    respond_to do |format|
      format.html { redirect_to(composers_path, status: :see_other, notice: "Composer was successfully destroyed.") }
    end
  end

  private
    def set_composer
      @composer = Composer.find(params.expect(:id))
    end

    def composer_params
      params.require(:composer).permit(:first_name, :last_name, :nationality_id, :birth_date, :death_date, :short_bio, :bio, :portrait)
    end
end
