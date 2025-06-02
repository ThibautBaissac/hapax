class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  def index
    @composers_count = Composer.count
    @works_count = Work.count
    @movements_count = Movement.count
    @quotes_count = Quote.count
  end
end
