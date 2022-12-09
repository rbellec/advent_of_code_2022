class Day09
  extend DailyProblemHelpers

  TEST_DATA_1 = <<~DATA
    R 4
    U 4
    L 3
    D 1
    R 4
    D 1
    L 5
    R 2
  DATA

  TEST_DATA_2 = <<~DATA
    R 5
    U 8
    L 8
    D 3
    R 17
    D 10
    L 25
    U 20
  DATA

  TEST_DATA = TEST_DATA_2

  class Coord
    attr_reader :x, :y

    alias_method :eql?, :==

    def initialize(x = 0, y = 0)
      # Check if < 0 ? Should we care ?
      puts " WARNING negative coordinate " if x < 0 || y < 0
      @x = x
      @y = y
    end

    def ==(other)
      if other.nil?
        false
      else
        x == other.x && y == other.y
      end
    end

    def up = Coord.new(x, y + 1)

    def down = Coord.new(x, y - 1)

    def left = Coord.new(x - 1, y)

    def right = Coord.new(x + 1, y)

    def move_toward(head)
      xmove = head.x <=> x
      ymove = head.y <=> y
      if (head.x - x).abs > 1 || (head.y - y).abs > 1
        Coord.new(x + xmove, y + ymove)
      else
        dup
      end
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

    def to_s
      "(#{x || "-"}, #{y || "-"})"
    end

    def to_h
      {x: x, y: y}
    end

    def to_a
      [x, y]
    end

    alias_method :inspect, :to_s
  end

  # kept to remember what I should not use anymore...
  class Instructions < Enumerator
    def self.from_stream(stream)
      input = stream.each_line
      Instructions.new do |yielder|
        loop do
          line = input.next
          direction, count_str = line.chomp!.strip.split(/\s+/)
          count_str.to_i.times { yielder << direction }
        end
      end
    end
  end

  class Path
    include Enumerable
    attr_reader :path, :instructions
    attr_writer :dimension
    attr_accessor :created_from

    delegate :each, to: :path

    def initialize(instructions: nil, path: nil, created_from: nil)
      @instructions = instructions
      @path = path
      @created_from = created_from
    end

    def build_path_from(initial_path, enum)
      initial_path = Array.wrap(initial_path)
      new_path = enum.reduce(initial_path) do |built_path, elem|
        built_path << yield(built_path.last, elem)
      end
      Path.new(path: new_path, created_from: self)
    end

    def path_from(start_coordinates)
      result_path = build_path_from(start_coordinates, instructions) do |current_coord, instruction|
        current_coord.single_move(instruction)
      end

      # Used only for visualisations.
      result_path.created_from = nil
      result_path
    end

    def track_from(track_start_coordinates)
      build_path_from(track_start_coordinates, path) do |current_coord, current_head_coordinate|
        current_coord.move_toward(current_head_coordinate)
      end
    end

    def dimension
      return created_from.dimension if created_from
      return @dimension if @dimension

      xs = path.map(&:x)
      ys = path.map(&:y)

      @dimension = {
        min_x: xs.min,
        min_y: ys.min,
        width: xs.max - xs.min,
        height: ys.max - ys.min
      }
    end

    def print
      rows = Array.new(dimension[:height] + 1) { Array.new(dimension[:width] + 1, ".") }
      start_x = - dimension[:min_x]
      start_y = - dimension[:min_y]
      path.each do |coord|
        rows[coord.y + start_y][coord.x + + start_x] = "#"
        # puts rows.reverse.map(&:join).join("\n")
        # sleep 0.3
      end
      puts rows.reverse.map(&:join).join("\n")
    end
  end

  def self.call(dataset: :test)
    solver = new(open_dataset(dataset: dataset))
    solver.problem_2
  end

  def initialize(data_stream)
    # @instructions = Instructions.from_stream(data_stream)
    @instructions = read(data_stream)
  end

  def read(stream)
    stream.each_line.flat_map do |line|
      direction, count_str = line.chomp!.strip.split(/\s+/)
      Array.new(count_str.to_i, direction)
    end
  end

  def problem_1
    head_start = Coord.new(0, 0)
    tail_start = Coord.new(0, 0)
    head_path = Path.new(instructions: instructions).path_from(head_start)
    # instructions.unshift("-").zip(head_path)

    tail_path = head_path.track_from(tail_start)

    # try graphics with curses ?
    head_path.print
    puts ""
    tail_path.print

    # tail_path.path.uniq(&:to_a).count
  end

  def problem_2
    origin = Coord.new(0, 0)

    head_path = Path.new(instructions: instructions).path_from(origin)
    tail_knot_path = (1..9).reduce(head_path) do |previous_knot, _index|
      previous_knot.track_from(origin)
    end

    # try graphics with curses ?
    # head_path.print
    puts ""
    tail_knot_path.print

    tail_knot_path.path.uniq(&:to_a).count
  end

  attr_reader :instructions
end
