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
module Kernel
  def async(type= :Concurrency ,&block)
    type= type.to_s
    case type.downcase[0]
      when "c"
        begin
          Asynchronous::Concurrency.new(block)
        end
      when "p"
        begin
          Asynchronous::Parallelism.new(block)
        end
      else
        nil

    end
  end
end