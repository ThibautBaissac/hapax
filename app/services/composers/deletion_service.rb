module Composers
  class DeletionService
    include ActiveModel::Model
    include ActiveModel::Validations
    include ServiceResult

    attr_reader :composer

    def initialize(composer)
      super()
      @composer = composer
    end

    def call
      return self unless composer.present?

      begin
        @composer.destroy!
        mark_success
      rescue ActiveRecord::RecordNotDestroyed => e
        errors.add(:base, "Could not delete composer: #{e.message}")
      rescue StandardError => e
        errors.add(:base, "An unexpected error occurred: #{e.message}")
      end

      self
    end
  end
end
