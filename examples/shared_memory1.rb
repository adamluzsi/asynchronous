require_relative "../lib/asynchronous"

SharedMemory.test_value= 0
async :OS do

  loop do
    SharedMemory.test_value += 1
    sleep 3
  end

end

loop do
  if shared_memory.test_value >= 10
    Process.exit
  end
  puts SharedMemory.test_value
  sleep 1
end
