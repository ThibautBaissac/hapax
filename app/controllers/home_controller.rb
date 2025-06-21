class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  def index
    @composers_count = Composer.count
    @works_count = Work.count
    @movements_count = Movement.count
    @quotes_count = Quote.count

    # If there's only one composer, make the page personalized
    if @composers_count == 1
      @composer = Composer.includes(:nationality, :works).first
      @composer_works_count = @composer.works.count
      @composer_quotes_count = @composer.quotes.count
    end
  end
end
