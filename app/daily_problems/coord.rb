class Coord
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def north = Coord.new(x, y - 1)

  def south = Coord.new(x, y + 1)

  def west = Coord.new(x - 1, y)

  def east = Coord.new(x + 1, y)

  # kept from day 14 ?
  def down_left = Coord.new(x - 1, y + 1)

  def down_right = Coord.new(x + 1, y + 1)

  def ==(other)
    x == other.x && y == other.y
  end

  alias_method :eql?, :==

  def to_s
    "(#{x}, #{y})"
  end

  alias_method :inspect, :to_s

  # Simplest
  def hash
    "#{x}:#{y}".hash
  end
end
