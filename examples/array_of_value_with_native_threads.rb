require 'asynchronous'

async1= async :OS do
  1000000*5
end

async2= async :OS do

  var = ('S' * 300000)
  puts "the superHuge String length in the pipe is: #{var.length}"
  var

end

async3= async :OS do
  1000000*5.0
end

puts async2.class

# puts [ async3, async2[0..5], async1 ]
