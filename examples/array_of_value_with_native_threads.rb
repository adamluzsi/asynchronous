require_relative "../lib/asynchronous"

async1= async :OS do

  1000000*5

end

async2= async :OS do

  sleep 10

  "sup" * 10000


end


async3= async :OS do

  1000000*5.0

end

# please do remember that parsing an object into
# Marshal String can take up time if you have big Strings like
# "sup" * 100000000

puts async1.value,
     async2.value[0..5],
     async3.value