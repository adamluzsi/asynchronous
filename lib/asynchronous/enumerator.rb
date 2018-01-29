class Asynchronous::Enumerator
  def initialize(scale, enum)
    @enum = enum
    @threads = []
    @pool = Asynchronous::Pool.new(scale)
  end

  def each(&block)
    unless block.nil?
      @threads.clear
      @enum.each do |*args|
        @threads << @pool.async { yield(*args) }
      end
    end
    self
  end

  def map
    each { |*args| yield(*args) }
    @threads.map(&:value)
  end

  def any?(&block)
    map(&block).include?(true)
  end

  def all?(&block)
    !map(&block).include?(false)
  end

  def to_a
    map { |e| e }
  end

  def to_h
    Hash[map { |k, v| [k,v] }]
  end
end
