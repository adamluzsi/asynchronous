require_relative "../lib/asynchronous"

calculation = async :parallelism do

  # Zombie!
  loop do
    sleep 1
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