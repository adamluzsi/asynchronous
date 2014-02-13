require_relative "../lib/asynchronous"

shared_memory.test_value= Array.new

async1v= async :OS do

  5.times do
    shared_memory.test_value.push Random.rand(0..9)
  end

  true

end

async2v= async :OS do

  5.times do
    shared_memory.test_value.push Random.rand(10..19)
  end

  true

end

async1v.value
async2v.value

puts "there should be 5 number between 0-9 and 5 between 10-19:",
     shared_memory.test_value.inspect

puts "this should be 10: #{shared_memory.test_value.count}"