require 'thread'

class Asynchronous::Pool
  def initialize(size)
    @size = size
    @pids = []
    @mutex = Mutex.new
  end

  def async(&block)
    thr = nil
    loop do
      @mutex.synchronize { thr = try(&block) }

      break if thr
    end
    thr
  end

  private

  def try(&block)
    filter_pids
    return unless @pids.length < @size
    thr = Asynchronous::Thread.new(&block)
    add_pid thr.instance_variable_get(:@pid)
    thr
  end

  def filter_pids
    @pids.select! { |pid| Asynchronous::Utils.alive?(pid) }
  end

  def add_pid(pid)
    @pids << pid
  end
end
