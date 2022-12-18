class Day14
  extend DailyProblemHelpers

  TEST_DATA_1 = <<~DATA
    498,4 -> 498,6 -> 496,6
    503,4 -> 502,4 -> 502,9 -> 494,9
  DATA

  TEST_DATA_2 = <<~DATA
    .
  DATA

  Coord = Struct.new(:x, :y) do
    # down_left and down_right coordinates
    def down_left = Coord.new(x - 1, y + 1)

    def down_right = Coord.new(x + 1, y + 1)
  end

  TEST_DATA = TEST_DATA_1

  def self.call(problem = false)
    dataset = problem ? :problem : :test
    day_solver = new(open_dataset(dataset: dataset))
    day_solver.problem_1
  end

  def self.call2(problem = false)
    dataset = problem ? :problem : :test
    day_solver = new(open_dataset(dataset: dataset))
    day_solver.problem_2
  end

  def initialize(data_stream)
    read(data_stream)
  end

  def read(stream)
    # 498,4 -> 498,6 -> 496,6
    @rock_paths = stream.each_line.map do |line|
      line.chomp!
      line.split(/\s+->\s+/).map { _1.split(",").map(&:to_i) }
    end

    xs = @rock_paths.map { |path| path.map(&:first) }.flatten
    ys = @rock_paths.map { |path| path.map(&:last) }.flatten

    # We could probably manage without considering full size. Sand going on left or right had a definite number of points,
    # But I wanted to try visualisation.
    @y_min = 0
    @y_max = ys.max + 2
    @map_height = y_max + 1

    @x_min = xs.min - map_height
    @x_max = xs.max + map_height

    # width will certainly be augmented
    @map_width = 1 + @x_max - @x_min
    @path_map = Array.new(map_height) { Array.new(map_width, false) }
    # @path_map will hold cells with either false, :sand or :rock

    @rock_paths.each { map_path(_1) }
    @transposed_map = @path_map.transpose

    # Set floor
    (x_min..x_max).each do |column|
      set_map_slot(Coord.new(column, y_max), :rock)
    end
  end

  def map_path(path)
    # Lines are always horizontal or vertical
    path.each_cons(2) do |line_start, line_end|
      x1, y1 = line_start
      x2, y2 = line_end

      # puts [line_start, line_end].map{_1.join(",")}.join(" | ")
      if x1 != x2
        x_range = [x1 - x_min, x2 - x_min].sort
        Range.new(*x_range).each do |x_rock|
          # byebug
          path_map[y1][x_rock] = :rock
        end
      elsif y1 != y2
        y_range = [y1, y2].sort
        Range.new(*y_range).each do |y_rock|
          path_map[y_rock][x1 - x_min] = :rock
        end
      else
        puts "ERROR: Line (#{line_start.join(",")}) to (#{line_end.join(",")})"
      end
    end
  end

  def print_map_status
    str = transposed_map.transpose.map do |row|
      row.map do |elem|
        case elem
        when :rock
          "#"
        when :sand
          "."
        else
          " "
        end
      end.join("")
    end.join("\n")

    puts str
  end

  def in_map?(coord)
    (x_min..x_max).cover?(coord.x) && (0..y_max).cover?(coord.y)
  end

  def map_slot(coord)
    transposed_map[coord.x - x_min][coord.y]
  end

  def set_map_slot(coord, value)
    transposed_map[coord.x - x_min][coord.y] = value
  end

  # A space is available it there is no sand or rock.
  # Abyss (out of map) is available (sand can fall there), other symbols (like pathway)
  # that could be used for visualisation are available
  def space_available?(coord)
    !in_map?(coord) || ![:rock, :sand].include?(map_slot(coord))
  end

  def column_of_map_for(coord)
    transposed_map[coord.x - x_min]
  end

  # Work on transposed map. Drop a sand grain on a specific element of the place
  # @return [Array] list of position where the grain of sand meet obstacles.
  #   The last element of the list is the rest position or nil if the grain of sand is doomed to the abyss.
  def dropped_sand_path(initial_sand_position)
    # End of map has been reached ?

    return [:void] unless in_map?(initial_sand_position)

    # byebug
    # Next obstacle:
    next_obstacle_y_from_drop = column_of_map_for(initial_sand_position).slice(initial_sand_position.y, y_max + 1).find_index(&:present?)

    if next_obstacle_y_from_drop.nil?
      # Falling into the abyss !
      [:void]
    else
      # Sand encounter an obstacles. Determine next path or if it rests there here.
      new_y = initial_sand_position.y + next_obstacle_y_from_drop - 1
      next_sand_position = Coord.new(initial_sand_position.x, new_y)

      # How to behave when new_y is above (when column is full) ?
      return [:full] if new_y < 0

      # Test diagonal left
      left_path = next_sand_position.down_left
      right_path = next_sand_position.down_right

      if space_available?(left_path)
        [next_sand_position] + dropped_sand_path(left_path)
      elsif space_available?(right_path)
        [next_sand_position] + dropped_sand_path(right_path)
      else
        # sand stops here
        [next_sand_position]
      end
    end
  end

  # return true if sand stays in map, false otherwise
  # Update transposed_map
  def drop_sand_and_actualize_map(x)
    # byebug
    first_sand_position = Coord.new(x, 0)
    sand_path = dropped_sand_path(first_sand_position)
    last_sand_position = sand_path.last
    case last_sand_position
    in Coord
      set_map_slot(last_sand_position, :sand)
      true
    in :void
      false
    in :full
      false
    end
  end

  def problem_1
    # Build map
    sand = 0
    print_map_status

    while drop_sand_and_actualize_map(500)
      sand += 1
      if sand % 1000 == 0
        print_map_status
        puts "sand: #{sand}"
      end
    end

    # 5.times { puts drop_sand_and_actualize_map(500) ? "Yes !" : "Finished" }
    print_map_status

    sand
  end

  def problem_2
  end

  attr_reader :rock_paths, :path_map, :x_min, :x_max, :y_min, :y_max, :map_width, :map_height
  attr_reader :transposed_map
end
