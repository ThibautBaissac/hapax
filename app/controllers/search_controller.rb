class SearchController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @query = params[:q]&.strip
    @results = {}

    if @query.present?
      @results = {
        composers: search_composers,
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

  def search_composers
    Composer.where(
      "first_name LIKE ? OR last_name LIKE ? OR nationality LIKE ? OR short_bio LIKE ? OR bio LIKE ?",
      "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%"
    ).limit(10)
  end

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
    MovementQuote.joins(:quote, movement: { work: :composer }).where(
      "quote_details.category LIKE ? OR quote_details.location LIKE ? OR quote_details.excerpt_text LIKE ? OR quote_details.notes LIKE ? OR quotes.title LIKE ? OR quotes.author LIKE ?",
      "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%"
    ).includes(:quote, movement: { work: :composer }).limit(10)
  end
end
