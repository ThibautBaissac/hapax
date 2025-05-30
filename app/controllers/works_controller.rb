class WorksController < ApplicationController
  before_action :set_composer
  before_action :set_work, only: %i[ show edit update destroy ]

  def index
    @pagy, @works = pagy(@composer.works.includes(:composer), items: 12)
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

    respond_to do |format|
      if @work.save
        format.html { redirect_to([@composer, @work], notice: "Work was successfully created.") }
      else
        format.html { render(:new, status: :unprocessable_entity) }
      end
    end
  end

  def update
    respond_to do |format|
      if @work.update(work_params)
        format.html { redirect_to([@composer, @work], notice: "Work was successfully updated.") }
      else
        format.html { render(:edit, status: :unprocessable_entity) }
      end
    end
  end

  def destroy
    @work.destroy!

    respond_to do |format|
      format.html { redirect_to(composer_works_path(@composer), status: :see_other, notice: "Work was successfully destroyed.") }
    end
  end

  private
    def set_composer
      @composer = Composer.find(params.expect(:composer_id))
    end

    def set_work
      @work = @composer.works.find(params.expect(:id))
    end

    def work_params
      params.expect(work: [ :opus, :title, :description, :duration ])
    end
end
