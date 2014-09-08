module Asynchronous
  # now let's see the Parallelism
  # you can use simple :p also instead of :parallelism
  # remember :parallelism is all about real OS thread case, so
  # you CANT modify the objects in memory only copy on write modify
  # This is ideal for big operations where you need do a big process
  # and only get the return value so you can do big works without the fear of the
  # Garbage collector slowness or the GIL lock
  # when you need to update objects in the memory use :concurrency
  class Parallelism < Asynchronous::CleanClass

    @@pids      ||= []
    @@motherpid ||= $$

    def initialize( callable )

      @comm_line   = ::IO.pipe
      @value       = nil
      @read_buffer = nil

      asynchronous_read_buffer
      @pid= asynchronous_fork callable
      @@pids.push(@pid)

    end

    def synchronize
      asynchronous_get_value
    end
    alias :sync :synchronize
    alias :call :synchronize

    protected

    def asynchronous_fork( callable )
      return ::Kernel.fork do

        ::GC.disable

        begin

          ::Kernel.trap("TERM") do
            ::Kernel.exit
          end
          ::Thread.new do
            ::Kernel.loop do
              begin
                ::Kernel.sleep 1
                if ::Asynchronous::Parallelism.asynchronous_alive?(@@motherpid) == false
                  ::Kernel.exit
                end
              end
            end
          end

        end

        @comm_line[0].close
        @comm_line[1].write ::Marshal.dump(callable.call)
        @comm_line[1].flush

      end
    end

    def asynchronous_read_buffer
      @read_buffer = ::Thread.new do
        while !@comm_line[0].eof?
          @value = ::Marshal.load(@comm_line[0])
        end
      end
    end

    def asynchronous_get_pid
      return @pid
    end

    def self.asynchronous_alive?(pid)
      begin
        ::Process.kill(0,pid)
        return true
      rescue ::Errno::ESRCH
        return false
      end
    end

    def asynchronous_get_value

      if @value.nil?

        ::Process.wait(@pid, ::Process::WNOHANG )
        @comm_line[1].close

        #> wait for value
        @read_buffer.join
        @comm_line[0].close

      end

      return @value

    end

    def asynchronous_set_value(obj)
      @value = obj
    end
    alias :asynchronous_set_value= :asynchronous_set_value

    def method_missing(method, *args)

      return_value = nil
      new_value = asynchronous_get_value
      begin
        original_value = new_value.dup
      rescue ::TypeError
        original_value = new_value
      end
      return_value = new_value.__send__(method,*args)
      unless new_value == original_value
        asynchronous_set_value new_value
      end

      return return_value

    end

    # kill kidos at Kernel Exit
    ::Kernel.at_exit do
      @@pids.each do |pid|
        begin
          ::Process.kill(:TERM, pid)
        rescue ::Errno::ESRCH, ::Errno::ECHILD
          #::STDOUT.puts "`kill': No such process (Errno::ESRCH)"
        end
      end
    end

  end
end