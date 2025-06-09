module Composers
  class CreationService
    include ActiveModel::Model
    include ServiceResult

    attr_accessor :first_name, :last_name, :nationality_id, :birth_date,
                  :death_date, :short_bio, :bio, :portrait

    def initialize(params = {})
      super()
      assign_attributes(params) if params.present?
      @composer = nil
    end

    def call
      @composer = Composer.new(composer_attributes)

      if @composer.save
        mark_success
      end

      self
    end

    def composer
      @composer
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
