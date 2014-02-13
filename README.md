Asynchronous
============

Asynchronous Patterns for Ruby Based on Pure MRI CRuby code
The goal is to use the original MRI C libs for achive
real async patterns in ruby

Well it is achived in Ruby really simple, and elegant way.


### Quoting Sun's Multithreaded Programming Guide:

Parallelism: 
- A condition that arises when at least two threads are executing simultaneously.

Concurrency: 
- A condition that exists when at least two threads are making progress. 
- A more generalized form of parallelism that can include time-slicing as a form of virtual parallelism

#### for short:

Concurrency is when two tasks can start, run, and complete in overlapping time periods.
It doesn't necessarily mean they'll ever both be running at the same instant.
Eg. multitasking on a single-core machine.

Parallelism is when tasks literally run at the same time.
Eg. on a multicore processor.


### OS managed thread (Native Threads)

copy on write memory share,
so you cant change anything in the mother process
only with the return value later.
This method is stronger the more CPU core the os have

Ideal for Big jobs that require lot of memory allocation or
heavy CPU load to get a value
Like parsing (in some case)

```ruby

calculation = async :parallelism do

  sleep 4
  # remember, everything you
  # write here only mather in this block
  # will not affect the real process only
  # the last return value of the block
  4 * 5

end

# to call the value (syncronize):
calculation

```

## VM managed thread (Green Threads)

you can use simple :c also instead of :concurrency as sym,
remember :concurrency is all about GIL case, so
you can modify the objects in memory
This is ideal for little operations in simultaneously or
when you need to update objects in the memory and not the
return value what is mather.
Remember well that GarbageCollector will affect the speed.

```ruby

calculation= async { sleep 3; 4 * 3 }
# to call the value (syncronize):
calculation

```

### Shared Memory

By default the last value will be returned (OS) in IO.pipe,
but when you need something else, there is the shared_memory!

Shared memory is good when you want make a ruby worked on native OS thread ,
but need to update data back at the mother process.

the usecase is simple like that:
```ruby

SharedMemory.anything_you_want_use_as_variable_name= {:some=>:object}
SharedMemory.anything_you_want_use_as_variable_name #> {:some=>:object}

# or

shared_memory.anything_you_want_use_as_variable_name #> {:some=>:object}

```

by default i set the memory allocation to 16Mb because it common usecase to me (MongoDB),
but feel free to change!:
```ruby

Asynchronous.memory_allocation_size= 1024 #INT!

```

## making shared memory obj static (constant)

you can set a shared memory obj to be static if you dont want it to be changed later on
```ruby
shared_memory.test_value= Array.new.push(:something)
Asynchronous.static_variables.push :test_value
shared_memory.test_value= Array.new #> this wont happen
```


### Example

```ruby

# you can use simple :p or :parallelism as nametag
# remember :parallelism is all about real OS thread case, so
# you CANT modify the objects in memory only in sharedmemories,
# the normal variables will only be copy on write modify
# This is ideal for big operations where you need do a big process
# w/o the fear of the Garbage collector slowness or the GIL lock
# when you need to update objects in the memory use SharedMemory
#
# Remember! if the hardware only got 1 cpu, it will be like a harder
# to use concurrency with an expensive memory allocation
calculation = async :OS do

  sleep 4
  4 * 5

end

calculation += 1

puts calculation

```


there are other examples that you can check in the exampels folder

### known bugs

In rare case when you get object_buffer error
* use .sync method on the async variable

```ruby
calculation = async :OS do
  sleep 4
  4 * 5
end

calculation.sync #> or synchronize
```

Kernel holding on Native threads with pipes can choke up
* direct sleep commands can do this on multiple native threads
** hard processing load not like that, only kernel sleep

SharedMemory objects not updating on chain method obj manipulation

```ruby
shared_memory.var= {'jobs'=>[]}

{'jobs'=>[]}['jobs'].push 'data' #> {'jobs'=>[]}

workaround is like that:

local_variable= {'jobs'=>[]}
local_variable['jobs'].push('data')

shared_memory.var= local_variable
```
