

begin
  10_000.times do
    Kernel.fork { sleep(10) }
  end
rescue Exception => exception
  puts exception.class
  puts exception
end
