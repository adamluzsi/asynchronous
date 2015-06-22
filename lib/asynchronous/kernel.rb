# kernel method for asyncron calls
# basic version is :
#
# var= async { "ruby Code here" }
# var.value #> "ruby Code here"
#
# or
#
# var = async :parallelism do
#  "some awsome ruby code here!"
# end
#
module Asynchronous::DCI

  extend self

  def async(type= :VM, &block)
    case type.to_s.downcase[0]

      # Concurrency / VM / Green
      when *%W[ c v g ]
        ::Asynchronous::Concurrency.new(&block)

      # Parallelism / OS / Native
      when *%W[ p o n ]
        ::Asynchronous::Parallelism.new(&block)

      else
        ::Asynchronous::Concurrency.new(&block)

    end
  end

end

Kernel.class_eval do

  def async(type=nil, &block)
    ::Asynchronous::DCI.async(type, &block)
  end

end