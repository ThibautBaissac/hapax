module Composers
  class UpdateService
    include ActiveModel::Model
    include ServiceResult

    attr_accessor :first_name, :last_name, :nationality_id, :birth_date,
                  :death_date, :short_bio, :bio, :portrait
    attr_reader :composer

    def initialize(composer, params = {})
      super()
      @composer = composer
      assign_attributes(params) if params.present?
    end

    def call
      if @composer.update(composer_attributes)
        mark_success
      end

      self
    end

    private

    def composer_attributes
      {
        first_name: first_name,
        last_name: last_name,
        nationality_id: nationality_id,
        birth_date: birth_date,
        death_date: death_date,
        short_bio: short_bio,
        bio: bio,
        portrait: portrait
      }.compact
    end
  end
end
