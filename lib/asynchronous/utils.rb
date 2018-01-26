module Asynchronous::Utils
  def alive?(pid)
    ::Process.kill(0, pid)
    return true
  rescue ::Errno::ESRCH
    return false
  end

  module_function :alive?
end
