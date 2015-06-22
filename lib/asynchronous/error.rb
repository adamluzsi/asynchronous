class Asynchronous::Error < StandardError

  attr_reader :wrapped_error
  def initialize(wrapped_error)
    @wrapped_error= wrapped_error
  end

end