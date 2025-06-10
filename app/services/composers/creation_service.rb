module Composers
  class CreationService < BaseService
    attr_reader :composer

    def initialize(params = {})
      super
      @params = params.to_h.with_indifferent_access
      @composer = nil
    end

    def call
      @composer = build_composer

      if @composer.save
        succeed!(@composer)
      else
        fail!(@composer.errors.full_messages)
      end
    end

    private

    attr_reader :params

    def build_composer
      Composer.new(params)
    end
  end
end
