class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  def index
    @composers_count = Composer.count
    @works_count = Work.count
    @movements_count = Movement.count
    @quotes_count = Quote.count
    @recent_composers = Composer.order(created_at: :desc).limit(3)
    @recent_quotes = Quote.order(created_at: :desc).limit(3)
  end
end
