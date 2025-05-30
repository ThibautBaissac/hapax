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
      if @quote.update(quote_params)
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
      params.expect(quote: [ :title, :author, :notes ])
    end
end
