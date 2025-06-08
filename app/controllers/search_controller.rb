class SearchController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @query = params[:q]&.strip
    @results = {}

    if @query.present?
      @results = {
        works: search_works,
        movements: search_movements,
        quotes: search_quotes,
        quote_details: search_quote_details
      }

      @total_results = @results.values.sum(&:count)
    else
      @total_results = 0
    end
  end

  private

  def search_works
    Work.joins(:composer).where(
      "works.title LIKE ? OR works.opus LIKE ? OR works.description LIKE ? OR composers.first_name LIKE ? OR composers.last_name LIKE ?",
      "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%"
    ).includes(:composer).limit(10)
  end

  def search_movements
    Movement.joins(work: :composer).where(
      "movements.title LIKE ? OR movements.description LIKE ? OR works.title LIKE ? OR composers.first_name LIKE ? OR composers.last_name LIKE ?",
      "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%"
    ).includes(work: :composer).limit(10)
  end

  def search_quotes
    Quote.where(
      "title LIKE ? OR author LIKE ? OR notes LIKE ?",
      "%#{@query}%", "%#{@query}%", "%#{@query}%"
    ).limit(10)
  end

  def search_quote_details
    # Search quote_details that are related to movements
    movement_quote_details = QuoteDetail.joins(:quote)
      .joins("JOIN movements ON movements.id = quote_details.detailable_id AND quote_details.detailable_type = 'Movement'")
      .joins("JOIN works ON works.id = movements.work_id")
      .joins("JOIN composers ON composers.id = works.composer_id")
      .where(
        "quote_details.category LIKE ? OR quote_details.location LIKE ? OR quote_details.excerpt_text LIKE ? OR quote_details.notes LIKE ? OR quotes.title LIKE ? OR quotes.author LIKE ? OR movements.title LIKE ? OR movements.description LIKE ? OR works.title LIKE ? OR composers.first_name LIKE ? OR composers.last_name LIKE ?",
        "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%"
      )

    # Search quote_details that are related to works directly
    work_quote_details = QuoteDetail.joins(:quote)
      .joins("JOIN works ON works.id = quote_details.detailable_id AND quote_details.detailable_type = 'Work'")
      .joins("JOIN composers ON composers.id = works.composer_id")
      .where(
        "quote_details.category LIKE ? OR quote_details.location LIKE ? OR quote_details.excerpt_text LIKE ? OR quote_details.notes LIKE ? OR quotes.title LIKE ? OR quotes.author LIKE ? OR works.title LIKE ? OR composers.first_name LIKE ? OR composers.last_name LIKE ?",
        "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%"
      )

    # Combine the results
    combined_ids = (movement_quote_details.pluck(:id) + work_quote_details.pluck(:id)).uniq

    # Return the final result with proper includes for eager loading
    QuoteDetail.where(id: combined_ids)
      .includes(:quote, :detailable)
      .limit(10)
  end
end
