module Asynchronous::Runtime
  extend(self)
  #
  # Number of processors seen by the OS and used for process scheduling.
  #
  # * AIX: /usr/sbin/pmcycles (AIX 5+), /usr/sbin/lsdev
  # * BSD: /sbin/sysctl
  # * Cygwin: /proc/cpuinfo
  # * Darwin: /usr/bin/hwprefs, /usr/sbin/sysctl
  # * HP-UX: /usr/sbin/ioscan
  # * IRIX: /usr/sbin/sysconf
  # * Linux: /proc/cpuinfo
  # * Minix 3+: /proc/cpuinfo
  # * Solaris: /usr/sbin/psrinfo
  # * Tru64 UNIX: /usr/sbin/psrinfo
  # * UnixWare: /usr/sbin/psrinfo
  #
  def num_cpu
    @NumCPU ||= begin
      if defined?(Etc) && Etc.respond_to?(:nprocessors)
        Etc.nprocessors
      else
        os_name = RbConfig::CONFIG['target_os']
        if os_name =~ /mingw|mswin/
          require 'win32ole'
          result = WIN32OLE.connect('winmgmts://').ExecQuery(
            'select NumberOfLogicalProcessors from Win32_Processor'
          )
          result.to_enum.collect(&:NumberOfLogicalProcessors).reduce(:+)
        elsif File.readable?('/proc/cpuinfo')
          IO.read('/proc/cpuinfo').scan(/^processor/).size
        elsif File.executable?('/usr/bin/hwprefs')
          IO.popen('/usr/bin/hwprefs thread_count').read.to_i
        elsif File.executable?('/usr/sbin/psrinfo')
          IO.popen('/usr/sbin/psrinfo').read.scan(/^.*on-*line/).size
        elsif File.executable?('/usr/sbin/ioscan')
          IO.popen('/usr/sbin/ioscan -kC processor') do |out|
            out.read.scan(/^.*processor/).size
          end
        elsif File.executable?('/usr/sbin/pmcycles')
          IO.popen('/usr/sbin/pmcycles -m').read.count("\n")
        elsif File.executable?('/usr/sbin/lsdev')
          IO.popen('/usr/sbin/lsdev -Cc processor -S 1').read.count("\n")
        elsif File.executable?('/usr/sbin/sysconf') && os_name =~ /irix/i
          IO.popen('/usr/sbin/sysconf NPROC_ONLN').read.to_i
        elsif File.executable?('/usr/sbin/sysctl')
          IO.popen('/usr/sbin/sysctl -n hw.ncpu').read.to_i
        elsif File.executable?('/sbin/sysctl')
          IO.popen('/sbin/sysctl -n hw.ncpu').read.to_i
        else
          raise('Unknown platform: ' + RbConfig::CONFIG['target_os'])
        end
      end
    end
  end

  def alive?(pid)
    try_collect_finished_child_process(pid)
    ::Process.kill(0, pid)
    return true
  rescue ::Errno::ESRCH
    return false
  end

  private

  def try_collect_finished_child_process(pid)
    ::Process.wait(pid, ::Process::WNOHANG)
  rescue ::Errno::ECHILD
    nil
  end
end
