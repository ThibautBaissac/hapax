class QuotesController < ApplicationController
  before_action :set_quote, only: %i[ show edit update destroy ]

  def index
    @pagy, @quotes = pagy(Quote.all, items: 12)
  end

  def show
  end

  def new
    @quote = Quote.new
  end

  def edit
  end

  def create
    @quote = Quote.new(quote_params)

    respond_to do |format|
      if @quote.save
        format.html { redirect_to(@quote, notice: "Quote was successfully created.") }
      else
        format.html { render(:new, status: :unprocessable_entity) }
      end
    end
  end

  def update
    respond_to do |format|
      handle_images
      # Update other attributes (excluding images which we handled above)
      update_params = quote_params.except(:images, :images_to_keep)

      if @quote.update(update_params)
        format.html { redirect_to(@quote, notice: "Quote was successfully updated.") }
      else
        format.html { render(:edit, status: :unprocessable_entity) }
      end
    end
  end

  def destroy
    @quote.destroy!

    respond_to do |format|
      format.html { redirect_to(quotes_path, status: :see_other, notice: "Quote was successfully destroyed.") }
    end
  end

  private

    def set_quote
      @quote = Quote.find(params.expect(:id))
    end

    def quote_params
      params.expect(quote: [ :title, :author, :notes, images: [], images_to_keep: [] ])
    end

    def handle_images
      # Get parameters
      new_images = params[:quote][:images]&.reject(&:blank?) || []
      images_to_keep = Array(params[:quote][:images_to_keep]).compact.reject(&:blank?)

      Rails.logger.debug "New images count: #{new_images.length}"
      Rails.logger.debug "Images to keep: #{images_to_keep}"

      # If we have existing images, handle removal
      if @quote.images.attached?
        # Only process removal if images_to_keep parameter was submitted
        # (this distinguishes between "keep all" and "remove some")
        if params[:quote].key?(:images_to_keep)
          @quote.images.each do |image|
            unless images_to_keep.include?(image.signed_id)
              Rails.logger.debug "Removing image: #{image.signed_id}"
              image.purge_later
            end
          end
        else
          Rails.logger.debug "No images_to_keep parameter found - keeping all existing images"
        end
      end

      # Attach new images if any
      if new_images.any?
        Rails.logger.debug "Attaching #{new_images.length} new images"
        @quote.images.attach(new_images)
      end
    end
end
