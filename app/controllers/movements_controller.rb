class MovementsController < ApplicationController
  before_action :set_composer_and_work
  before_action :set_movement, only: %i[ show edit update destroy ]

  def show
  end

  def new
    @movement = @work.movements.build
  end

  def edit
  end

  def create
    @movement = @work.movements.build(movement_params)

    respond_to do |format|
      if @movement.save
        format.html { redirect_to([@composer, @work, @movement], notice: "Movement was successfully created.") }
      else
        format.html { render(:new, status: :unprocessable_entity) }
      end
    end
  end

  def update
    respond_to do |format|
      if @movement.update(movement_params)
        format.html { redirect_to([@composer, @work, @movement], notice: "Movement was successfully updated.") }
      else
        format.html { render(:edit, status: :unprocessable_entity) }
      end
    end
  end

  def destroy
    @movement.destroy!

    respond_to do |format|
      format.html { redirect_to(composer_work_path(@composer, @work), status: :see_other, notice: "Movement was successfully destroyed.") }
    end
  end

  private
    def set_composer_and_work
      @composer = Composer.find(params.expect(:composer_id))
      @work = @composer.works.find(params.expect(:work_id))
    end

    def set_movement
      @movement = @work.movements.find(params.expect(:id))
    end

    def movement_params
      params.expect(movement: [ :title, :position, :duration, :description ])
    end
end
