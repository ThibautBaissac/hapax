module Composers
  class FacadeService
    def self.paginate(page: 1, limit: 12)
      PaginationService.call(page: page, limit: limit)
    end

    def self.create(params)
      service = CreationService.new(params)
      service.call
      service
    end

    def self.update(composer, params)
      service = UpdateService.new(composer, params)
      service.call
      service
    end

    def self.delete(composer)
      service = DeletionService.new(composer)
      service.call
      service
    end
  end
end
