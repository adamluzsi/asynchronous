require_relative "../lib/asynchronous"

shared_memory.ruby_worker_jobs= Array.new
shared_memory.static_variables.push :ruby_worker_jobs

class Worker

  def self.do_some_hard_work! *args

    puts "heavy db load job here with params #{args.inspect}"
    #some brutal DB work here

  end

  def self.add_job *array
    shared_memory.ruby_worker_jobs.push array
  end

end


async :OS do

  loop do

    unless shared_memory.ruby_worker_jobs.empty?

      puts "job to do again..."
      job= shared_memory.ruby_worker_jobs.pop

      model_name  = job.shift
      method_name = job.shift

      model_name.__send__(method_name,*job)

      puts "everything is done, so... nothing to do here... *sigh*"

    else
      sleep 0.1
    end


  end

end



loop do

  sleep 6
  Worker.add_job Worker,:do_some_hard_work!,{random: Random.srand}

end
