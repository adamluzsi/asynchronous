#encoding: UTF-8
module Asynchronous

  require 'process_shared'

  require File.join(File.dirname(__FILE__),"asynchronous","clean_class")
  require File.join(File.dirname(__FILE__),"asynchronous","concurrency")
  require File.join(File.dirname(__FILE__),"asynchronous","parallelism")
  require File.join(File.dirname(__FILE__),"asynchronous","shared_memory")
  require File.join(File.dirname(__FILE__),"asynchronous","kernel")

end
