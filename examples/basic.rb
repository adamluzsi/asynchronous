# Require Gemfile gems
require_relative 'bootstrap'

thr1 = async do
  sleep 2
  4 * 2
end

calculation1 = thr1.value
calculation1 += 1
puts calculation1
