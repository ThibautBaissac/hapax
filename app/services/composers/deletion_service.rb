module Composers
  class DeletionService < BaseService
    attr_reader :composer

    def initialize(composer)
      super()
      @composer = composer
    end

    def call
      return fail!("Composer not found") unless @composer.present?

      begin
        ApplicationRecord.transaction do
          @composer.destroy!
          succeed!(@composer)
        end
      rescue ActiveRecord::RecordNotDestroyed => e
        fail!("Could not delete composer: #{e.message}")
      rescue StandardError => e
        fail!("An unexpected error occurred: #{e.message}")
      end
    end
  end
end
