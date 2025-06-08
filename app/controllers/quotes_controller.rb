class QuotesController < ApplicationController
  before_action :set_composer
  before_action :set_work, except: [:index]
  before_action :set_movement, only: [:show, :new, :edit, :create, :update, :destroy]
  before_action :set_quote, only: [:show, :edit, :update, :destroy]
  before_action :set_detailable, only: [:new, :create]

  def index
    @quotes = @composer.quotes.order(:title)
  end

  def show
  end

  def new
    @quote = Quote.new
    @quote.quote_details.build(detailable: @detailable)

    # Get existing quotes from the current composer that are not already linked to this detailable
    # Use a more explicit approach to handle the polymorphic association
    existing_quote_ids = QuoteDetail.where(
      detailable_type: @detailable.class.name,
      detailable_id: @detailable.id
    ).pluck(:quote_id)

    @existing_quotes = @composer.quotes
                               .where.not(id: existing_quote_ids)
                               .order(:title)
  end

  def edit
  end

  def create
    # Check if user wants to link an existing quote
    if params[:existing_quote_id].present?
      @quote = Quote.find(params[:existing_quote_id])

      # Create only the quote detail association
      quote_detail = @quote.quote_details.build(
        detailable: @detailable,
        category: params[:quote_detail]&.dig(:category),
        location: params[:quote_detail]&.dig(:location),
        excerpt_text: params[:quote_detail]&.dig(:excerpt_text),
        notes: params[:quote_detail]&.dig(:notes)
      )

      respond_to do |format|
        if quote_detail.save
          redirect_path = @movement ? [@composer, @work, @movement, @quote] : [@composer, @work, @quote]
          format.html { redirect_to(redirect_path, notice: "Quote was successfully linked.") }
        else
          existing_quote_ids = QuoteDetail.where(
            detailable_type: @detailable.class.name,
            detailable_id: @detailable.id
          ).pluck(:quote_id)

          @existing_quotes = @composer.quotes
                                     .where.not(id: existing_quote_ids)
                                     .order(:title)
          format.html { render(:new, status: :unprocessable_entity) }
        end
      end
    else
      # Create a new quote
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
          existing_quote_ids = QuoteDetail.where(
            detailable_type: @detailable.class.name,
            detailable_id: @detailable.id
          ).pluck(:quote_id)

          @existing_quotes = @composer.quotes
                                     .where.not(id: existing_quote_ids)
                                     .order(:title)
          format.html { render(:new, status: :unprocessable_entity) }
        end
      end
    end
  end

  def update
    respond_to do |format|
      # Handle image removal logic
      if @quote.images.attached? && params[:quote]&.has_key?(:keep_images)
        keep_image_ids = Array(params[:quote][:keep_images]).map(&:to_i)
        @quote.images.each do |image|
          image.purge unless keep_image_ids.include?(image.id)
        end
      end

      # Handle new images separately to avoid replacing existing ones
      new_images = params[:quote][:images] if params[:quote]&.key?(:images)

      # Update quote attributes (excluding images to prevent replacement)
      quote_params = params.require(:quote).permit(:title, :author, :notes)

      if @quote.update(quote_params)
        # Attach new images if any were uploaded
        @quote.images.attach(new_images) if new_images&.any?
        # Update quote details if present
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
