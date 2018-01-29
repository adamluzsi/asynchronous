module Asynchronous::Enumerable
  def concurrently(scale = Asynchronous::Utils.processor_count)
    Asynchronous::Enumerator.new(scale, to_enum)
  end
end
