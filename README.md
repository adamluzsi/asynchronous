Asynchronous
============

Asynchronous Patterns for Ruby Based on Pure MRI CRuby code
The goal is to use the original MRI C libs for achieve
real async processing in ruby

This is good for where cpu focused for included,
for example csv transformation

### Example

```ruby
require 'asynchronous/core_ext'

thr = async do
    "some expensive work"
end

thr.value #> "some expensive work"
```


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
