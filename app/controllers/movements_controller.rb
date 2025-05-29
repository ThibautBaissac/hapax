class MovementsController < ApplicationController
  before_action :set_movement, only: %i[ show edit update destroy ]

  def index
    @pagy, @movements = pagy(Movement.includes(work: :composer), items: 12)
  end

  def show
  end

  def new
    @movement = Movement.new
  end

  def edit
  end

  def create
    @movement = Movement.new(movement_params)

    respond_to do |format|
      if @movement.save
        format.html { redirect_to(@movement, notice: "Movement was successfully created.") }
      else
        format.html { render(:new, status: :unprocessable_entity) }
      end
    end
  end

  def update
    respond_to do |format|
      if @movement.update(movement_params)
        format.html { redirect_to(@movement, notice: "Movement was successfully updated.") }
      else
        format.html { render(:edit, status: :unprocessable_entity) }
      end
    end
  end

  def destroy
    @movement.destroy!

    respond_to do |format|
      format.html { redirect_to(movements_path, status: :see_other, notice: "Movement was successfully destroyed.") }
    end
  end

  private
    def set_movement
      @movement = Movement.find(params.expect(:id))
    end

    def movement_params
      params.expect(movement: [ :title, :work_id, :position, :duration, :description ])
    end
end
