class WorksController < ApplicationController
  before_action :set_composer
  before_action :set_work, only: %i[show edit update destroy]

  def index
    @works = @composer.works.includes(:movements, :quotes)
  end

  def show
  end

  def new
    @work = @composer.works.build
  end

  def edit
  end

  def create
    @work = @composer.works.build(work_params)

    if @work.save
      redirect_to([@composer, @work], notice: success_message(:created))
    else
      render(:new, status: :unprocessable_entity)
    end
  end

  def update
    if @work.update(work_params)
      redirect_to([@composer, @work], notice: success_message(:updated))
    else
      render(:edit, status: :unprocessable_entity)
    end
  end

  def destroy
    if @work.destroy
      redirect_to(composer_works_path(@composer), status: :see_other, notice: success_message(:destroyed))
    else
      redirect_to([@composer, @work], alert: @work.errors.full_messages.join(", "))
    end
  end

  private

  def set_composer
    @composer = Composer.find(params[:composer_id])
  end

  def set_work
    @work = @composer.works.find(params[:id])
  end

  def work_params
    params.expect(work: [
      :opus, :title, :description, :duration, :form, :structure,
      :instrumentation, :recorded, :start_date_composed, :end_date_composed,
      :unsure_start_date, :unsure_end_date
    ])
  end

  def success_message(action)
    t("works.messages.#{action}")
  end
end
