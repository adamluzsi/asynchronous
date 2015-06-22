# you can use simple :c also instead of :concurrency
# remember :concurrency is all about GIL case, so
# you can modify the objects in memory
# This is ideal for little operations in simultaneously or
# when you need to update objects in the memory
class Asynchronous::Concurrency < Asynchronous::CleanClass

  def initialize(&block)

    @rescue_state= nil
    @try_count = 0

    begin
      @value= nil
      @thread ||= ::Thread.new { block.call }
      @rescue_state= nil
    rescue ThreadError
      @rescue_state ||= true
      @try_count += 1
      if 3 <= @try_count
        @value= block.call
        @rescue_state= nil
      else
        sleep 5
        retry
      end
    end

  end

  def join
    if @value.nil?
      until @rescue_state.nil?
        sleep 1
      end
      @value= @thread.value
    end
  end

  def value
    join; @value
  end

end
