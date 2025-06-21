class QuotesController < ApplicationController
  before_action :set_composer
  before_action :set_work, except: [:index]
  before_action :set_movement, only: [:show, :new, :edit, :create, :update, :destroy]
  before_action :set_quote, only: [:show, :edit, :update, :destroy]
  before_action :set_detailable, only: [:new, :create, :edit, :update]
  before_action :load_existing_quotes, only: [:new, :create]

  def index
    @quotes = @composer.quotes.includes(:quote_details).order(:title)
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
    if params[:existing_quote_id].present?
      link_existing_quote
    else
      create_new_quote
    end
  end

  def update
    handle_image_management

    if @quote.update(quote_params)
      update_quote_details
      redirect_to(quote_path, notice: success_message(:updated))
    else
      render(:edit, status: :unprocessable_entity)
    end
  end

  def destroy
    if @quote.destroy
      redirect_to(detailable_path, status: :see_other, notice: success_message(:destroyed))
    else
      redirect_to(quote_path, alert: @quote.errors.full_messages.join(", "))
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

    def load_existing_quotes
      existing_quote_ids = QuoteDetail.where(
        detailable_type: @detailable.class.name,
        detailable_id: @detailable.id
      ).pluck(:quote_id)

      @existing_quotes = @composer.quotes
                                 .where.not(id: existing_quote_ids)
                                 .order(:title)
    end

    def link_existing_quote
      @quote = Quote.find(params[:existing_quote_id])
      quote_detail = @quote.quote_details.build(quote_detail_params.merge(detailable: @detailable))

      if quote_detail.save
        redirect_to(quote_path, notice: success_message(:linked))
      else
        load_existing_quotes
        render(:new, status: :unprocessable_entity)
      end
    end

    def create_new_quote
      @quote = Quote.new(quote_params)

      if @quote.save
        @quote.quote_details.create!(quote_detail_params.merge(detailable: @detailable))
        redirect_to(quote_path, notice: success_message(:created))
      else
        load_existing_quotes
        render(:new, status: :unprocessable_entity)
      end
    end

    def handle_image_management
      if @quote.images.attached? && params[:quote]&.has_key?(:keep_images)
        keep_image_ids = Array(params[:quote][:keep_images]).map(&:to_i)
        @quote.images.each { |image| image.purge unless keep_image_ids.include?(image.id) }
      end

      # Attach new images
      new_images = params[:quote][:images] if params[:quote]&.key?(:images)
      @quote.images.attach(new_images) if new_images&.any?
    end

    def update_quote_details
      return unless @quote.quote_details.any? && params[:quote_detail].present?

      quote_detail = @quote.quote_details.find_by(detailable: @detailable)
      quote_detail&.update(quote_detail_params)
    end

    def quote_path
      @movement ? [@composer, @work, @movement, @quote] : [@composer, @work, @quote]
    end

    def detailable_path
      @movement ? [@composer, @work, @movement] : [@composer, @work]
    end

    def quote_params
      params.expect(quote: [:title, :author, :notes, :date, :circa, images: []])
    end

    def quote_detail_params
      return {} unless params[:quote_detail].present?

      params.expect(quote_detail: [:category, :location, :excerpt_text, :notes])
    end

    def success_message(action)
      t("quotes.messages.#{action}")
    end
end
