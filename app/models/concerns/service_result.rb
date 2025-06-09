module ServiceResult
  extend ActiveSupport::Concern

  included do
    attr_reader :success
  end

  def initialize(*args)
    super
    @success = false
  end

  def success?
    @success == true
  end

  def failure?
    !success?
  end

  private

  def mark_success
    @success = true
  end
end
