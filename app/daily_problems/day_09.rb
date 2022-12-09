class Day09
  extend DailyProblemHelpers

  TEST_DATA = <<~DATA
    R 4
    U 4
    L 3
    D 1
    R 4
    D 1
    L 5
    R 2
  DATA

  class Coord
    attr_reader :x, :y
    def initialize(x=0, y=0)
      @x = x
      @y = y
    end

    def up = new(x, y+1)
    def down = new(x, y-1)
    def left = new(x-1, y)
    def right = new(x+1, y)

    def move_toward(head)
      xmove = head.x <=> x
      ymove = head.y <=> y
      new(x+xmove, y+ymove)
    end
  end

  def self.call(dataset: :test)
    new(open_dataset(dataset: dataset))

    # new.problem_2
  end

  def initialize(data_stream)
    @motion_inputs = read(data_stream)
  end

  def read(stream)
    stream.readlines.map do |line|
      direction, count = line.chomp!.strip.split(/\s+/)
    end
  end

  attr_reader :motion_inputs, :tree_columns

end
