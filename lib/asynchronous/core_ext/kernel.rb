require 'asynchronous'
#
# kernel method for asyncron calls
# basic version is :
#
# thr = async { "ruby Code here" }
# thr.value #> "ruby Code here"
#
Kernel.class_eval do
  def async(&block)
    ::Asynchronous::Thread.new(&block)
  end
end
