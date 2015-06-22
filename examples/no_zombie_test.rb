require_relative 'bootstrap'

thr = async :parallelism do

  # Zombie!
  loop do
    sleep 1
    puts "brains(#{$$})"
  end
  # inf loop
  #

end

puts $$
Thread.new do

  sleep 5

  # this want to demonstrate that,
  # if the main process is killed,
  # you wont leave zombies behind!
  system "kill -9 #{$$}"

end

loop do
  sleep 1
end