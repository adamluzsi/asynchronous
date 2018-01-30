require 'asynchronous'
#
# kernel method for asyncron calls
#
# thr = async { "ruby Code here" }
# thr.value #> "ruby Code here"
#
::Thread.main[:AsynchronousGlobalPool] ||= ::Asynchronous::Pool.new(::Asynchronous::Runtime.num_cpu)
#
Kernel.class_eval do
  def async(&block)
    ::Thread.main[:AsynchronousGlobalPool].async(&block)
  end
end
