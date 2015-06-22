require_relative 'bootstrap'

async1= async :OS do
  1000000*5
end

async2= async :OS do

  var = ("!" * 1000000)
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

begin
  async2_error.value
rescue Exception => ex
  puts "\n",'when error happen:',ex
end

puts "\n",'result length based on string form:'
puts async1.value.to_s.length
puts async2.value.to_s.length
puts async3.value.to_s.length