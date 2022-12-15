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

  def manhattan_distance(other)
    (x-other.x).abs + (y-other.y).abs
  end

  alias_method :eql?, :==

  def to_s(resolution = nil)
    if resolution
      "(%#{resolution}d, %#{resolution}d)" % [x, y]
    else
      "(#{x}, #{y})"
    end
  end

  alias_method :inspect, :to_s

  # Simplest
  def hash
    "#{x}:#{y}".hash
  end
end
