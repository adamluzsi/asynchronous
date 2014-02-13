# Require Gemfile gems
require_relative "../lib/asynchronous"

# you can use simple :c also instead of :concurrency
# remember :concurrency is all about GIL case, so
# you can modify the objects in memory
# This is ideal for little operations in simultaneously or
# when you need to update objects in the memory
calculation = async :concurrency do

  sleep 2
  4 * 2

end
puts "hello concurrency"

calculation += 1

puts calculation

#>--------------------------------------------------
# or you can use simple {} without sym and this will be by default a
# :concurrency pattern

calculation = async { sleep 3; 4 * 3 }

puts "hello simple concurrency"

calculation += 1

# remember you have to use  to cal the return value from the code block!
puts calculation


#>--------------------------------------------------
# now let's see the Parallelism
# you can use simple :p or :parallelism as nametag
# remember :parallelism is all about real OS thread case, so
# you CANT modify the objects in memory only in sharedmemories,
# the normal variables will only be copy on write modify
# This is ideal for big operations where you need do a big process
# w/o the fear of the Garbage collector slowness or the GIL lock
# when you need to update objects in the memory use SharedMemory
calculation = async :parallelism do

  sleep 4
  4 * 5

end
puts "hello parallelism"

calculation += 1

puts calculation

#>--------------------------------------------------

# more complex way

puts "mixed usecase with arrays as return obj"
calc1 = async :parallelism do

  sleep 4
  # some big database processing brutal memory eater stuff
  [4*5,"hy"]

end

calc2 = async {
  [5+1,"sup!"]
}

puts calc1 == calc2
puts (calc1+calc2).inspect

