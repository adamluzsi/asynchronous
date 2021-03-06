require 'enumerator'

class Asynchronous::Enumerator
  def initialize(scale, enum)
    @scale = scale
    @enum = enum
    @threads = []
    @pool = Asynchronous::Pool.new(scale)
  end

  def each(&block)
    raise if block.nil?
    @enum.each do |args|
      @pool.async { yield(args) }
    end
    self
  end

  def map
    @enum.map do |args|
      @pool.async { yield(args) }
    end.map(&:value)
  end

  def any?(&block)
    map(&block).map { |e| !!e }.include?(true)
  end

  def all?(&block)
    !map(&block).map{|e| !!e }.include?(false)
  end

  def to_a
    map { |e| e }
  end

  def to_h
    Hash[map { |k, v| [k, v] }]
  end
end
