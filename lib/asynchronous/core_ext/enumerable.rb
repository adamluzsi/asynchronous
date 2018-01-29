require 'asynchronous'
Enumerable.module_eval do
  def concurrently(scale)
    puts self
    pool = Asynchronous::Pool.new(scale)

    Enumerator.new do |yielder|
      # pool.async { yielder.yield }
    end
  end
end
