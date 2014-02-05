module Asynchronous
  # now let's see the Parallelism
  # you can use simple :p also instead of :parallelism
  # remember :parallelism is all about real OS thread case, so
  # you CANT modify the objects in memory only copy on write modify
  # This is ideal for big operations where you need do a big process
  # and only get the return value so you can do big works without the fear of the
  # Garbage collector slowness or the GIL lock
  # when you need to update objects in the memory use :concurrency
  class Parallelism < CleanClass

    # Basic class variables
    begin

      @@pids      ||= []
      @@tmpdir    ||= nil
      @@motherpid ||= $$
      @@agent     ||= nil
      @@zombie    ||= true
      ::Kernel.require 'yaml'

    end

    # main def for logic
    begin
      def initialize callable

        # defaults
        begin
          @value= nil
          @rd, @wr = ::IO.pipe
        end

        # create a process
        begin
          @pid= ::Kernel.fork do

            # anti zombie
            begin
              ::Kernel.trap("TERM") do
                ::Kernel.exit
              end
              ::Thread.new do
                ::Kernel.loop do
                  begin
                    ::Kernel.sleep 1
                    if alive?(@@motherpid) == false
                      ::Kernel.exit!
                    end
                  end
                end
              end
            end

            # return the value
            begin

              #::Kernel.puts callable.class

              return_value= callable.call

              @rd.close

              #@wr.write ::Marshal.dump(return_value)
              @wr.write return_value.to_yaml

              @wr.close

              ::Process.exit!
            end

          end
          @@pids.push(@pid)
        end

      end
    end

    # connection for in case of mother die
    begin

      def alive?(pid)
        begin
          ::Process.kill(0,pid)
          return true
          rescue ::Errno::ESRCH
          return false
        end
      end

    end

    # return value
    begin

      def value

        if @value.nil?

          #while alive?(@pid)
          #  ::Kernel.puts alive? @pid
          #  ::Kernel.sleep 1
          #  #sleep 1
          #end

          @wr.close
          return_value= @rd.read
          @rd.close

          #return_value= ::Marshal.load(return_value)
          return_value= ::YAML.load(return_value)

          @@pids.delete(@pid)
          @value= return_value

        end

        return @value

      end

      def value=(obj)
        @value= obj
      end

    end

    # kill kidos at Kernel Exit
    begin
      ::Kernel.at_exit {
        @@pids.each { |pid|
          begin
            ::Process.kill(:TERM, pid)
          rescue ::Errno::ESRCH, ::Errno::ECHILD
            #::STDOUT.puts "`kill': No such process (Errno::ESRCH)"
          end
        }
      }
    end

    # alias
    begin
      alias :v        :value
      #alias :get      :value
      #alias :gets     :value
      #alias :response :value
      #alias :return   :value
    end

  end
end