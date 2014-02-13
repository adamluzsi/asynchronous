require_relative "../lib/asynchronous"

shared_memory.test_value  = Array.new
shared_memory.ready_state = Hash.new
times_value= 5

times_value.times do

  # remember! IO pipes cant be made too fast!
  # this does not mean the Shared memory cant handle the speed

  var= async :OS do

    shared_memory.test_value.push $$
    shared_memory.ready_state[$$]= true

    nil
  end
  shared_memory.ready_state[var.asynchronous_get_pid] ||= false

end


while shared_memory.ready_state.values.include?(false)
  sleep 0.5
end

puts shared_memory.test_value.inspect
puts "#{times_value} OS thread should made this much shared memory update: #{times_value} / and it's #{shared_memory.test_value.count}"