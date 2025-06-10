module Composers
  class UpdateService < BaseService
    attr_reader :composer

    def initialize(composer, params = {})
      super
      @composer = composer
      @params = params.to_h.with_indifferent_access
    end

    def call
      return fail!("Composer not found") unless @composer.present?

      if @composer.update(params)
        succeed!(@composer)
      else
        fail!(@composer.errors.full_messages)
      end
    end

    private

    attr_reader :params
  end
end
