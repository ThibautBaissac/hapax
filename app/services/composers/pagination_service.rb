module Composers
  class PaginationService
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :page, :limit

    validates :page, numericality: { greater_than: 0 }
    validates :limit, numericality: { greater_than: 0, less_than_or_equal_to: 100 }

    def initialize(page: 1, limit: 12)
      @page = page.to_i.positive? ? page.to_i : 1
      @limit = limit.to_i.positive? ? limit.to_i : 12
    end

    def call
      validate!

      composers = composer_scope
      pagy = Pagy.new(count: composers.count, page: page, limit: limit)

      [pagy, composers.offset(pagy.offset).limit(pagy.limit)]
    rescue Pagy::OverflowError => e
      raise e
    end

    private

    def composer_scope
      Composer.includes(:nationality)
    end
  end
end
