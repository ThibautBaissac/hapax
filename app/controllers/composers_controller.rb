class ComposersController < ApplicationController
  before_action :set_composer, only: %i[show edit update destroy]
  before_action :load_nationalities, only: %i[new edit]

  rescue_from Pagy::OverflowError, with: :redirect_to_first_page

  def index
    @pagy, @composers = pagy(Composer.includes(:nationality), items: 12)
  end

  def show
  end

  def new
    @composer = Composer.new
  end

  def edit
  end

  def create
    @composer = Composer.new(composer_params)

    if @composer.save
      redirect_to(@composer, notice: success_message(:created))
    else
      load_nationalities
      render(:new, status: :unprocessable_entity)
    end
  end

  def update
    if @composer.update(composer_params)
      redirect_to(@composer, notice: success_message(:updated))
    else
      load_nationalities
      render(:edit, status: :unprocessable_entity)
    end
  end

  def destroy
    if @composer.destroy
      redirect_to(composers_path, status: :see_other, notice: success_message(:destroyed))
    else
      redirect_to(@composer, alert: @composer.errors.full_messages.join(", "))
    end
  end

  private

  def set_composer
    @composer = Composer.find(params[:id])
  end

  def load_nationalities
    @nationalities ||= Nationality.ordered
  end

  def composer_params
    params.expect(composer: [ :first_name, :last_name, :nationality_id, :birth_date, :death_date,
    :short_bio, :bio, :portrait ])
  end

  def success_message(action)
    t("composers.messages.#{action}")
  end

  def redirect_to_first_page
    redirect_to(composers_path)
  end
end
