class QuotesController < ApplicationController
  before_action :set_composer
  before_action :set_work, except: [:index]
  before_action :set_movement, only: [:show, :new, :edit, :create, :update, :destroy]
  before_action :set_quote, only: [:show, :edit, :update, :destroy]
  before_action :set_detailable, only: [:new, :create]

  def index
    # Quotes index for a specific composer
    @quotes = Quote.joins(:quote_details)
                   .where(quote_details: { detailable: [@composer.works, @composer.works.joins(:movements).select("movements.*")].flatten })
                   .distinct
                   .order(:title)
  end

  def show
  end

  def new
    @quote = Quote.new
    @quote.quote_details.build(detailable: @detailable)
  end

  def edit
  end

  def create
    @quote = Quote.new(quote_params)

    respond_to do |format|
      if @quote.save
        # Create the quote detail association
        @quote.quote_details.create!(
          detailable: @detailable,
          category: params[:quote_detail]&.dig(:category),
          location: params[:quote_detail]&.dig(:location),
          excerpt_text: params[:quote_detail]&.dig(:excerpt_text),
          notes: params[:quote_detail]&.dig(:notes)
        )

        redirect_path = @movement ? [@composer, @work, @movement, @quote] : [@composer, @work, @quote]
        format.html { redirect_to(redirect_path, notice: "Quote was successfully created.") }
      else
        format.html { render(:new, status: :unprocessable_entity) }
      end
    end
  end

  def update
    respond_to do |format|
      if @quote.update(quote_params)
        # Update the quote detail if present
        if @quote.quote_details.any? && params[:quote_detail].present?
          quote_detail = @quote.quote_details.first
          quote_detail.update(
            category: params[:quote_detail][:category],
            location: params[:quote_detail][:location],
            excerpt_text: params[:quote_detail][:excerpt_text],
            notes: params[:quote_detail][:notes]
          )
        end

        redirect_path = @movement ? [@composer, @work, @movement, @quote] : [@composer, @work, @quote]
        format.html { redirect_to(redirect_path, notice: "Quote was successfully updated.") }
      else
        format.html { render(:edit, status: :unprocessable_entity) }
      end
    end
  end

  def destroy
    @quote.destroy!

    respond_to do |format|
      redirect_path = @movement ? [@composer, @work, @movement] : [@composer, @work]
      format.html { redirect_to(redirect_path, status: :see_other, notice: "Quote was successfully destroyed.") }
    end
  end

  private

    def set_composer
      @composer = Composer.find(params[:composer_id])
    end

    def set_work
      @work = @composer.works.find(params[:work_id]) if params[:work_id]
    end

    def set_movement
      @movement = @work.movements.find(params[:movement_id]) if params[:movement_id] && @work
    end

    def set_quote
      if @movement
        @quote = Quote.joins(:quote_details).where(quote_details: { detailable: @movement }).find(params[:id])
      elsif @work
        @quote = Quote.joins(:quote_details).where(quote_details: { detailable: @work }).find(params[:id])
      end
    end

    def set_detailable
      @detailable = @movement || @work
    end

    def quote_params
      params.require(:quote).permit(:title, :author, :notes, images: [])
    end
end
