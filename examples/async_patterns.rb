# Require Gemfile gems
require_relative 'bootstrap'

# you can use simple :c also instead of :concurrency
# remember :concurrency is all about GIL case, so
# you can modify the objects in memory
# This is ideal for little operations in simultaneously or
# when you need to update objects in the memory
thr1 = async :concurrency do

  sleep 2
  4 * 2

end
puts "hello concurrency"

calculation1 = thr1.value
calculation1 += 1

puts calculation1

#>--------------------------------------------------
# or you can use simple {} without sym and this will be by default a
# :concurrency pattern

thr2 = async { sleep 3; 4 * 3 }

puts "hello simple concurrency"

calculation2 = thr2.value
calculation2 += 1

# remember you have to use  to cal the return value from the code block!
puts calculation2


#>--------------------------------------------------
# now let's see the Parallelism
# you can use simple :p or :parallelism as nametag
# remember :parallelism is all about real OS thread case, so
# you CANT modify the objects in memory only in sharedmemories,
# the normal variables will only be copy on write modify
# This is ideal for big operations where you need do a big process
# w/o the fear of the Garbage collector slowness or the GIL lock
# when you need to update objects in the memory use SharedMemory
thr3 = async :parallelism do

  sleep 4
  4 * 5

end
puts "hello parallelism"

calculation3 = thr3.value
calculation3 += 1

puts calculation3

#>--------------------------------------------------

# more complex way

puts "mixed usecase with arrays as return obj"
thr4 = async :parallelism do

  sleep 4
  # some big database processing brutal memory eater stuff
  [4*5,"hy"]

end

thr5 = async {
  [5+1,"sup!"]
}

puts 'calc1 is eql calc2:',thr4.value == thr5.value
puts (thr4.value+thr5.value).inspect

