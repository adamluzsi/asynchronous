begin

  require 'process_shared'
  module Asynchronous

    class << self
      attr_accessor :global_mutex
    end
    self.global_mutex = false

    class << self
      attr_accessor :memory_allocation_size
    end
    self.memory_allocation_size= 16384

    module Global

      def self.mutex
        @@mutex
      end

      @@mutex  = ProcessShared::Mutex.new

    end


    class MemoryObj < Asynchronous::CleanClass

      @data  = nil
      @mutex = nil

      def initialize(obj)

        @data= ::ProcessShared::SharedMemory.new(
            ::Asynchronous.memory_allocation_size)

        @mutex= ::ProcessShared::Mutex.new

        @data.write_object(obj)

      end

      def asynchronous_set_value obj
        return @data.write_object obj
      end
      alias :asynchronous_set_value= :asynchronous_set_value

      def asynchronous_get_value
        return @data.read_object
      end

      def method_missing(method, *args, &block)

        #::Kernel.puts "method: #{method}, #{args}, #{block}"

        new_value= nil
        original_value= nil
        return_value= nil
        mutex_obj= nil

        if ::Asynchronous.global_mutex == true
          mutex_obj= ::Asynchronous::Global.mutex
        else
          mutex_obj= @mutex
        end

        mutex_obj.synchronize do

          new_value = asynchronous_get_value

          begin
            original_value= new_value.dup
          rescue ::TypeError
            original_value= new_value
          end

          return_value= new_value.__send__(method,*args,&block)

          unless new_value == original_value
            asynchronous_set_value new_value
          end

        end

        return return_value

      end

    end

    class SharedMemory < Asynchronous::CleanClass
      class << self
        def method_missing(method, *args)

          case true

            when method.to_s.include?('=')

              @@static_variables ||= ::Asynchronous::MemoryObj.new(Array.new.push(:static_variables))
              if @@static_variables.include?(method.to_s.sub!('=','').to_sym)
                $stdout.puts "Warning! static varieble cant be changed without removing from the Asynchronous.static_variables array collection (sym)"
                return nil
              else

                begin
                  self.class_variable_get("@@#{method.to_s.sub('=','')}").asynchronous_set_value= args[0]
                rescue ::NameError
                  self.class_variable_set(
                      "@@#{method.to_s.sub('=','')}",
                      ::Asynchronous::MemoryObj.new(args[0]))
                end

              end

            else
              begin
                self.class_variable_get("@@#{method.to_s}")
              rescue ::NameError
                return nil
              end
          end

        end
      end
    end

    def self.static_variables
      SharedMemory.static_variables
    end

  end

  SharedMemory ||= Asynchronous::SharedMemory

=begin


      # The C void type; only useful for function return types
      :void => Type::VOID,

      # C boolean type
      :bool => Type::BOOL,

      # C nul-terminated string
      :string => Type::STRING,

      # C signed char
      :char => Type::CHAR,
      # C unsigned char
      :uchar => Type::UCHAR,

      # C signed short
      :short => Type::SHORT,
      # C unsigned short
      :ushort => Type::USHORT,

      # C signed int
      :int => Type::INT,
      # C unsigned int
      :uint => Type::UINT,

      # C signed long
      :long => Type::LONG,

      # C unsigned long
      :ulong => Type::ULONG,

      # C signed long long integer
      :long_long => Type::LONG_LONG,

      # C unsigned long long integer
      :ulong_long => Type::ULONG_LONG,

      # C single precision float
      :float => Type::FLOAT,

      # C double precision float
      :double => Type::DOUBLE,

      # C long double
      :long_double => Type::LONGDOUBLE,

      # Native memory address
      :pointer => Type::POINTER,

      # 8 bit signed integer
      :int8 => Type::INT8,
      # 8 bit unsigned integer
      :uint8 => Type::UINT8,

      # 16 bit signed integer
      :int16 => Type::INT16,
      # 16 bit unsigned integer
      :uint16 => Type::UINT16,

      # 32 bit signed integer
      :int32 => Type::INT32,
      # 32 bit unsigned integer
      :uint32 => Type::UINT32,

      # 64 bit signed integer
      :int64 => Type::INT64,
      # 64 bit unsigned integer
      :uint64 => Type::UINT64,

      :buffer_in => Type::BUFFER_IN,
      :buffer_out => Type::BUFFER_OUT,
      :buffer_inout => Type::BUFFER_INOUT,

      # Used in function prototypes to indicate the arguments are variadic
      :varargs => Type::VARARGS,


=end

rescue LoadError
  $stderr.puts('You must run `gem install process_shared` in order to use shared memory')
end