require_relative 'bootstrap'

nums = [1, 2, 3].concurrently.map do |num|
  sleep(1) # extensive work
  num + 100
end

p nums
