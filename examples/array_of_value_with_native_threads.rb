require_relative 'bootstrap'

async1= async :OS do
  1000000*5
end

async2= async :OS do

  var = ("sup" * 100000)
  puts "the superHuge String length in the pipe is: #{var.length}"

  var
end

async2_error= async :OS do

  raise(SystemExit)
  puts 'never happen, to system error happened!'

end


async3= async :OS do
  1000000*5.0
end

puts async1.value

puts async2.value

begin
  async2_error.value
rescue Exception => ex
  puts ex
end

# puts [ async3, async2.join[0..5], async1 ]
