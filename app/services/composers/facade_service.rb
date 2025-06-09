module Composers
  class FacadeService
    def self.paginate(page: 1, limit: 12)
      PaginationService.new(page: page, limit: limit).call
    end

    def self.create(params)
      CreationService.new(params).call
    end

    def self.update(composer, params)
      UpdateService.new(composer, params).call
    end

    def self.delete(composer)
      DeletionService.new(composer).call
    end
  end
end
