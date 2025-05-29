class WorksController < ApplicationController
  before_action :set_work, only: %i[ show edit update destroy ]

  def index
    @pagy, @works = pagy(Work.includes(:composer), items: 12)
  end

  def show
  end

  def new
    @work = Work.new
  end

  def edit
  end

  def create
    @work = Work.new(work_params)

    respond_to do |format|
      if @work.save
        format.html { redirect_to(@work, notice: "Work was successfully created.") }
      else
        format.html { render(:new, status: :unprocessable_entity) }
      end
    end
  end

  def update
    respond_to do |format|
      if @work.update(work_params)
        format.html { redirect_to(@work, notice: "Work was successfully updated.") }
      else
        format.html { render(:edit, status: :unprocessable_entity) }
      end
    end
  end

  def destroy
    @work.destroy!

    respond_to do |format|
      format.html { redirect_to(works_path, status: :see_other, notice: "Work was successfully destroyed.") }
    end
  end

  private
    def set_work
      @work = Work.find(params.expect(:id))
    end

    def work_params
      params.expect(work: [ :opus, :title, :description, :duration, :composer_id ])
    end
end
