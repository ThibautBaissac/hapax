class CitationsController < ApplicationController
  before_action :set_citation, only: %i[ show edit update destroy ]

  def index
    @pagy, @citations = pagy(Citation.all, items: 12)
  end

  def show
  end

  def new
    @citation = Citation.new
  end

  def edit
  end

  def create
    @citation = Citation.new(citation_params)

    respond_to do |format|
      if @citation.save
        format.html { redirect_to(@citation, notice: "Citation was successfully created.") }
      else
        format.html { render(:new, status: :unprocessable_entity) }
      end
    end
  end

  def update
    respond_to do |format|
      if @citation.update(citation_params)
        format.html { redirect_to(@citation, notice: "Citation was successfully updated.") }
      else
        format.html { render(:edit, status: :unprocessable_entity) }
      end
    end
  end

  def destroy
    @citation.destroy!

    respond_to do |format|
      format.html { redirect_to(citations_path, status: :see_other, notice: "Citation was successfully destroyed.") }
    end
  end

  private

    def set_citation
      @citation = Citation.find(params.expect(:id))
    end

    def citation_params
      params.expect(citation: [ :title, :author, :notes ])
    end
end
