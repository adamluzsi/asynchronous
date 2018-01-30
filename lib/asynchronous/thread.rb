class Asynchronous::Thread
  def initialize(&callable)
    @value = nil
    @value_received = false

    open_pipe
    read_buffer
    fork(callable)
  end

  def join
    wait
    nil until @value_received
    raise(@value.wrapped_error) if @value.is_a?(::Asynchronous::Error)
    self
  end

  def kill
    ::Process.kill('KILL', @pid)

    wait
  rescue Errno::ESRCH
    nil
  end

  def status
    alive? ? 'run' : false
  end

  def value
    join; @value
  end

  protected

  def alive?
    ::Asynchronous::Runtime.alive?(@pid)
  end

  def wait(flag = 0)
    ::Process.wait(@pid, flag)
  rescue Errno::ECHILD
    nil
  end

  def fork(callable)
    @pid = ::Kernel.fork { main(&callable) }
  end

  def read_buffer
    ::Thread.new do
      nil until @pid
      @write.close
      @value = Marshal.load(@read)
      @read.close
      @value_received = true
    end
  end

  def main
    ::Asynchronous::ZombiKiller.antidote

    @read.close

    result = begin
      yield
    rescue ::Exception => ex
      ::Asynchronous::Error.new(ex)
    end

    write_result!(result)
  end

  def write_result!(result)
    ::Marshal.dump(result, @write)
    @write.flush
    @write.close
  rescue Errno::EPIPE
    nil
  end

  def open_pipe
    @read, @write = ::IO.pipe
  rescue ::Errno::EMFILE
    retry
  end
end
