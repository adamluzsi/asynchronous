module Asynchronous::ZombiKiller
  MOTHER_PID ||= $$

  def antidote
    Thread.main[:ZombiKiller] ||= ::Thread.new do
      loop do
        ::Kernel.exit unless Asynchronous::Runtime.alive?(MOTHER_PID)

        ::Kernel.sleep(1)
      end
    end
  end

  module_function :antidote

end