module Asynchronous::Enumerable
  def concurrently(scale = Asynchronous::Runtime.num_cpu)
    Asynchronous::Enumerator.new(scale, to_enum)
  end
end
