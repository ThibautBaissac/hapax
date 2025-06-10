class BaseService
  attr_reader :success

  def initialize(*args)
    @success = false
    @errors = []
  end

  def self.call(*args)
    new(*args).call
  end

  def call
    raise(NotImplementedError, "Subclasses must implement #call")
  end

  def success?
    @success
  end

  def failure?
    !@success
  end

  def errors
    ErrorWrapper.new(@errors)
  end

  private

  def succeed!(result = nil)
    @success = true
    @result = result
    self
  end

  def fail!(errors = [])
    @success = false
    @errors = Array(errors).flatten
    self
  end

  # Wrapper class to provide full_messages method for test compatibility
  class ErrorWrapper
    def initialize(errors)
      @errors = Array(errors)
    end

    def full_messages
      @errors
    end

    def any?
      @errors.any?
    end

    def empty?
      @errors.empty?
    end

    def to_a
      @errors
    end

    def [](index)
      @errors[index]
    end

    def each(&block)
      @errors.each(&block)
    end

    def include?(message)
      @errors.include?(message)
    end
  end
end
