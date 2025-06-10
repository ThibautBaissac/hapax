 module Composers
  class PaginationService
    DEFAULT_PAGE = 1
    DEFAULT_LIMIT = 12
    MAX_LIMIT = 100

    def initialize(page: DEFAULT_PAGE, limit: DEFAULT_LIMIT)
      @page = normalize_page(page)
      @limit = normalize_limit(limit)
    end

    def self.call(page: DEFAULT_PAGE, limit: DEFAULT_LIMIT)
      new(page: page, limit: limit).call
    end

    def call
      composers = composer_scope
      pagy = Pagy.new(count: composers.count, page: page, limit: limit)

      paginated_composers = composers.offset(pagy.offset).limit(pagy.limit)

      [ pagy, paginated_composers ]
    rescue Pagy::OverflowError => e
      raise(e)
    rescue StandardError => e
      [ nil, Composer.none ]
    end

    private

    attr_reader :page, :limit

    def normalize_page(page_param)
      page_param.to_i.positive? ? page_param.to_i : DEFAULT_PAGE
    end

    def normalize_limit(limit_param)
      limit_int = limit_param.to_i
      return DEFAULT_LIMIT unless limit_int.positive?
      [ limit_int, MAX_LIMIT ].min
    end

    def composer_scope
      Composer.includes(:nationality).order(:last_name, :first_name)
    end
  end
 end
