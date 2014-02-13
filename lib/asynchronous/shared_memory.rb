require 'process_shared'
require_relative "clean_class"
module Asynchronous


  module Allocation

    class << self
      attr_accessor :memory_allocation_size
    end

    self.memory_allocation_size= 16384

    def self.mutex
      @@mutex
    end

    @@mutex  = ProcessShared::Mutex.new

  end


  class MemoryObj < CleanClass

    attr_accessor :data

    def initialize(obj)

      self.data= ::ProcessShared::SharedMemory.new(
          ::Asynchronous::Allocation.memory_allocation_size
      )

      self.data.write_object(obj)
    end

    def set_value obj
      return self.data.write_object obj
    end

    def set_value= obj
      self.set_value(obj)
    end

    def get_value
      return self.data.read_object
    end

    def method_missing(method, *args)

      new_value= nil
      original_value= nil
      return_value= nil

      ::Asynchronous::Allocation.mutex.synchronize do

        new_value= get_value
        original_value= new_value.dup
        return_value= new_value.__send__(method,*args)
        unless new_value == original_value
          set_value new_value
        end

      end

      return return_value

    end

  end

  class SharedMemory < CleanClass
    class << self
      def method_missing(method, *args)

          if method.to_s.include?('=')
            begin
              self.class_variable_get("@@#{method.to_s.sub('=','')}").set_value= args[0]
            rescue ::NameError
              self.class_variable_set(
                  "@@#{method.to_s.sub('=','')}",
                  ::Asynchronous::MemoryObj.new(args[0])
              )
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

