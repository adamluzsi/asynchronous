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
module Asynchronous

  module EXT

    def async( type= :VM, &block )

      case type.to_s.downcase[0]
        # Concurrency / VM / Green
        when "c","v","g"
          begin
            ::Asynchronous::Concurrency.new(block)
          end
        # Parallelism / OS / Native
        when "p","o","n"
          begin
            ::Asynchronous::Parallelism.new(block)
          end
        else
          begin
            ::Asynchronous::Concurrency.new(block)
          end

      end

    end

  end

  extend EXT

end

Object.__send__ :include, Asynchronous::EXT

# module Kernel
#   def async type= :VM ,&block
#     ::Asynchronous.async( type, &block )
#   end
# end