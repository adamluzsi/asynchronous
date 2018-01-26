module Asynchronous::ZombiKiller
  MOTHER_PID ||= $$

  def how_is_mom?
    Asynchronous::Utils.alive?(MOTHER_PID)
  end

  def antidote
    Thread.main[:ZombiKiller] ||= ::Thread.new do
      loop do
        ::Kernel.exit unless how_is_mom?

        ::Kernel.sleep(1)
      end
    end
  end

  module_function :antidote, :how_is_mom?

end