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
    def initialize(x = 0, y = 0)
      @x = x
      @y = y
    end

    def up = new(x, y + 1)

    def down = new(x, y - 1)

    def left = new(x - 1, y)

    def right = new(x + 1, y)

    def move_toward(head)
      xmove = head.x <=> x
      ymove = head.y <=> y
      new(x + xmove, y + ymove)
    end

    # return a new coordinate for new position after instruction.
    def single_move(instruction)
      case instruction
      when "U"
        up
      when "D"
        down
      when "L"
        left
      when "R"
        right
      end
    end
  end

  def self.call(dataset: :test)
    new(open_dataset(dataset: dataset)).motion_inputs

    # new.problem_2
  end

  def initialize(data_stream)
    # @motion_inputs = data_stream.each_line.enum_for(unit_instructions_from()
    @motion_inputs = unit_instructions_from(data_stream)
  end

  def instructions_from_lines
    Enumerator.new do |yielder|
      line = yielder.next
      direction, count = line.chomp!.strip.split(/\s+/)
      count.times { yielder << direction }
    end
  end

  def unit_instructions_from(stream)
    input = stream.each_line
    Enumerator.new do |yielder|
      loop do
        line = input.next
        direction, count_str = line.chomp!.strip.split(/\s+/)
        count_str.to_i.times { yielder << direction }
      end
    end
  end

  attr_reader :motion_inputs
end
