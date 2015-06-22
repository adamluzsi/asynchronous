# now let's see the Parallelism
# you can use simple :p also instead of :parallelism
# remember :parallelism is all about real OS thread case, so
# you CANT modify the objects in memory only copy on write modify
# This is ideal for big operations where you need do a big process
# and only get the return value so you can do big works without the fear of the
# Garbage collector slowness or the GIL lock
# when you need to update objects in the memory use :concurrency
class Asynchronous::Parallelism

  attr_reader :pid

  @@pids ||= []
  @@motherpid ||= $$

  def initialize(&callable)

    @comm_line = ::IO.pipe

    @value = nil
    @read_buffer = nil

    read_buffer
    @pid = fork(&callable)
    @@pids.push(@pid)

  end

  def self.alive?(pid)
    ::Process.kill(0, pid)
    return true
  rescue ::Errno::ESRCH
    return false
  end

  def join
    if @value.nil?

      ::Process.wait(@pid, ::Process::WNOHANG)

      @comm_line[1].close
      @read_buffer.join
      @comm_line[0].close

      if @value.is_a?(::Asynchronous::Error)
        raise(@value.wrapped_error)
      end

    end; self
  end

  def value
    join; @value
  end

  protected

  def pipe_read
    @comm_line[0]
  end

  def pipe_write
    @comm_line[1]
  end

  def fork(&block)
    return ::Kernel.fork do

      begin
        ::Kernel.trap("TERM") do
          ::Kernel.exit
        end
        ::Thread.new do
          ::Kernel.loop do
            begin
              ::Kernel.sleep 1
              if ::Asynchronous::Parallelism.alive?(@@motherpid) == false
                ::Kernel.exit
              end
            end
          end
        end
      end

      @comm_line[0].close

      result = begin
        block.call
      rescue ::Exception => ex
        ::Asynchronous::Error.new(ex)
      end

      dumped_result = ::Marshal.dump(result).to_s

      @comm_line[1].write(dumped_result)
      ::Kernel.sleep(dumped_result.length*0.001)

      @comm_line[1].flush
      @comm_line[1].close

    end
  end

  def read_buffer
    @read_buffer = ::Thread.new do
      while !@comm_line[0].eof?

        begin
          @value = ::Marshal.load(@comm_line[0])
        rescue ::ArgumentError => ex
          sleep(1)
          retry if ex.respond_to?(:message) && ex.message =~ /marshal data too short/i
        end

      end
    end
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