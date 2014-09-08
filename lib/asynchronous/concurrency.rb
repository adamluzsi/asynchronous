module Asynchronous

  # you can use simple :c also instead of :concurrency
  # remember :concurrency is all about GIL case, so
  # you can modify the objects in memory
  # This is ideal for little operations in simultaneously or
  # when you need to update objects in the memory
  class Concurrency < Asynchronous::CleanClass

    def initialize( callable )
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

    def synchronize
      asynchronous_get_value
    end
    alias :sync :synchronize
    alias :call :synchronize

    protected

    def method_missing(method, *args)

      new_value= asynchronous_get_value

      begin
        original_value= new_value.dup
      rescue ::TypeError
        original_value= new_value
      end

      return_value= new_value.__send__(method,*args)
      unless new_value == original_value
        asynchronous_set_value new_value
      end

      return return_value

    end

    def asynchronous_get_value

      if @value.nil?
        until @rescue_state.nil?
          sleep 1
        end
        @value= @thread.value
      end

      return @value

    end

    def asynchronous_set_value(obj)
      @value= obj
    end
    alias :asynchronous_set_value= :asynchronous_set_value

  end

end
