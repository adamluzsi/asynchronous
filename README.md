asynchronous
============

Asynchronous Patterns for Ruby Based on Pure MRI CRuby code
The goal is to use the original MRI C libs for achive
real async patterns in ruby

Well it is achived in Ruby really simple, and elegant way.


## Quoting Sun's Multithreaded Programming Guide:

Parallelism: 
- A condition that arises when at least two threads are executing simultaneously.

Concurrency: 
- A condition that exists when at least two threads are making progress. 
- A more generalized form of parallelism that can include time-slicing as a form of virtual parallelism

### for short:

Concurrency is when two tasks can start, run, and complete in overlapping time periods.
It doesn't necessarily mean they'll ever both be running at the same instant.
Eg. multitasking on a single-core machine.

Parallelism is when tasks literally run at the same time.
Eg. on a multicore processor.


## OS managed thread (Native Threads)

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
calculation.value

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
calculation.value

```
# Examples

the "async patterns" will let you see how easy to use threads 
for multiprocessing so you can give multiple task to do and
until you need they value, let the process run in the background

## LICENSE

(The MIT License)

Copyright (c) 2009-2013 Adam Luzsi <adamluzsi@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
