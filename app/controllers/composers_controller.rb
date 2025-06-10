class ComposersController < ApplicationController
  before_action :set_composer, only: %i[show edit update destroy]
  before_action :load_nationalities, only: %i[new edit]

  rescue_from Pagy::OverflowError, with: :redirect_to_first_page
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :bad_request

  def index
    @pagy, @composers = Composers::FacadeService.paginate(
      page: params[:page],
      limit: 12
    )
  end

  def show
  end

  def new
    @composer = Composer.new
  end

  def edit
  end

  def create
    service = Composers::FacadeService.create(composer_params)

    if service.success?
      redirect_to(service.composer, notice: success_message(:created))
    else
      @composer = service.composer || Composer.new(composer_params)
      load_nationalities
      render(:new, status: :unprocessable_entity)
    end
  end

  def update
    service = Composers::FacadeService.update(@composer, composer_params)

    if service.success?
      redirect_to(service.composer, notice: success_message(:updated))
    else
      load_nationalities
      render(:edit, status: :unprocessable_entity)
    end
  end

  def destroy
    service = Composers::FacadeService.delete(@composer)

    if service.success?
      redirect_to(composers_path, status: :see_other, notice: success_message(:destroyed))
    else
      redirect_to(@composer, alert: service.errors.full_messages.join(", "))
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

  def record_not_found
    render(file: "#{Rails.root}/public/404.html", status: :not_found, layout: false)
  end

  def bad_request
    head(:bad_request)
  end
end
