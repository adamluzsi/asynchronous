class Asynchronous::Thread
  def initialize(&callable)
    @value = nil
    @value_received = false
    @read, @write = ::IO.pipe
    read_buffer

    @pid = fork(&callable)
  end

  def join
    wait
    receive_value! unless @value_received
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
    ::Asynchronous::Utils.alive?(@pid)
  end

  def receive_value!
    @write.close
    read_buffer.join
    @read.close
    @value_received = true
  end

  def wait(flag = 0)
    ::Process.wait(@pid, flag)
  rescue Errno::ECHILD
    nil
  end

  def fork(&callable)
    ::Kernel.fork { main(&callable) }
  end

  def read_buffer
    @read_buffer ||= ::Thread.new do
      @value = Marshal.load(@read)
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
    return unless Asynchronous::ZombiKiller.how_is_mom?
    ::Marshal.dump(result, @write)
    @write.flush
    @write.close
  rescue Errno::EPIPE
    nil
  end
end

# Marshal.load(File.binread(FNAME))
