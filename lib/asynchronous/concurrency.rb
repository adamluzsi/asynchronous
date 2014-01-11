module Asynchronous

  # you can use simple :c also instead of :concurrency
  # remember :concurrency is all about GIL case, so
  # you can modify the objects in memory
  # This is ideal for little operations in simultaneously or
  # when you need to update objects in the memory
  class Concurrency < CleanClass

    def initialize(callable)
      begin
        @value= nil
        @try_count= 0
        @rescue_state= nil
        @thread ||= ::Thread.new { callable.call }
        @rescue_state= nil
      rescue ThreadError
        @rescue_state ||= true
        @try_count += 1
        if 3 <= @try_count
          @value= callable.call
          @rescue_state= nil
        else
          sleep 5
          retry
        end
      end
    end

    def value

      if @value.nil?
        until @rescue_state.nil?
          sleep 1
        end
        @value= @thread.value
      end

      return @value

    end

    def value=(obj)
      @value= obj
    end

    def inspect
      if @thread.alive?
        "#<Async running>"
      else
        value.inspect
      end
    end

    def method_missing(method, *args)
      value.__send__(method, *args)
    end

    def respond_to_missing?(method, include_private = false)
      value.respond_to?(method, include_private)
    end

  end

end
