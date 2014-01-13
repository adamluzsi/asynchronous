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
                    if mother? == false
                      ::Kernel.exit!
                    end
                  end
                end
              end
            end

            # return the value
            begin
              @rd.close
              @wr.write ::Marshal.dump(callable.call)
              @wr.close
            end

          end
          @@pids.push(@pid)
        end

      end
    end

    # connection for in case of mother die
    begin

      #def tmpdir
      #
      #  ::Kernel.require "tmpdir"
      #  @@tmpdir= ::File.join(::Dir.tmpdir,('asynchronous'))
      #  unless ::File.directory?(@@tmpdir)
      #    ::Dir.mkdir(@@tmpdir)
      #  end
      #
      #  %w[ signal ].each do |one_str|
      #    unless ::File.directory?(::File.join(@@tmpdir,one_str))
      #      ::Dir.mkdir(::File.join(@@tmpdir,one_str))
      #    end
      #  end
      #
      #  # pidnamed tmp file for tracking
      #  unless ::File.exist?(::File.join(@@tmpdir,'signal',@@motherpid.to_s))
      #    ::File.new(::File.join(@@tmpdir,'signal',@@motherpid.to_s),"w").write('')
      #  end
      #
      #end
      #
      #def tmp_write_agent
      #  if @@agent != true
      #    ::Thread.new do
      #      ::Kernel.loop do
      #        ::File.open(::File.join(@@tmpdir,"signal",@@motherpid.to_s),"w") do |file|
      #          file.write( ::Time.now.to_i.to_s )
      #        end
      #        sleep 3
      #      end
      #    end
      #    @@agent ||= true
      #  end
      #end
      #
      #def tmp_read
      #
      #  counter= 0
      #  begin
      #
      #    ::Kernel.loop do
      #      return_string= ::File.open(
      #          ::File.join(@@tmpdir,"signal",@@motherpid.to_s),
      #          ::File::RDONLY
      #      ).read
      #
      #      if !return_string.nil? && return_string != ""
      #        return return_string
      #      else
      #        if counter > 5
      #          return nil
      #        else
      #          counter += 1
      #          ::Kernel.sleep(1)
      #        end
      #      end
      #
      #    end
      #
      #  rescue ::IOError
      #    if counter > 5
      #      return nil
      #    else
      #      counter += 1
      #    end
      #    ::Kernel.sleep 1
      #    retry
      #  end
      #
      #end

      def mother?
        begin
          ::Process.kill(0,@@motherpid)
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

          @wr.close
          return_value= ::Marshal.load(return_value)
          @rd.close
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
            ::STDOUT.puts "`kill': No such process (Errno::ESRCH)"
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