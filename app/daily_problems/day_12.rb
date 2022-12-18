class Day12
  extend DailyProblemHelpers

  ELEM_OUTPUT_SIZE = 5

  Node = Struct.new(:x, :y) do
    def north = Node.new(x, y - 1)

    def south = Node.new(x, y + 1)

    def west = Node.new(x - 1, y)

    def east = Node.new(x + 1, y)
  end

  TEST_DATA_1 = <<~DATA
    Sabqponm
    abcryxxl
    accszExk
    acctuvwj
    abdefghi
  DATA

  TEST_DATA_2 = <<~DATA
    .
  DATA

  TEST_DATA = TEST_DATA_1

  def self.call(problem = false)
    dataset = problem ? :problem : :test
    day_solver = new(open_dataset(dataset: dataset))
    day_solver.problem_2
  end

  attr_reader :origin, :destination, :map_width, :map_height
  attr_reader :distance_matrix, :height_map

  def initialize(data_stream)
    read(data_stream)
    @distance_matrix = Array.new(map_height) { Array.new(map_width, false) }
    set_distance(origin, 0)
  end

  def read(stream)
    # Read height map
    @height_map = stream.each_line.map do |line|
      line.chomp!.codepoints
    end

    @map_width = @height_map.first.size
    @map_height = @height_map.size

    # Get origin&destination and replace with their level
    @height_map.each_with_index do |row, y|
      row.each_with_index do |item, x|
        case item
        when 83 # 'S'
          @origin = Node.new(x, y)
          @height_map[y][x] = 97 # a
        when 69 # 'E'
          @destination = Node.new(x, y)
          @height_map[y][x] = 122 # z
        end
      end
    end
  end

  # return 1 if node in x,y exists and can be reached by height current_height, false otherwise
  def distance_to(current_height, destination_node)
    if in_map?(destination_node) && (current_height + 1 >= @height_map[destination_node.y][destination_node.x])
      1
    else
      false
    end
  end

  # Calculate all shortest_paths
  def shortest_paths_from(node)
    current_distance = distance(node)
    current_height = height(node)
    calculates_paths_from = []

    # Consider all valid neigbour nodes
    neighbours = [:north, :south, :east, :west].map { node.send(_1) }.filter { in_map?(_1) }

    neighbours.each do |neighbour|
      target_distance_from_origin = distance(neighbour)
      distance_to_target_from_here = distance_to(current_height, neighbour)

      if distance_to_target_from_here &&
          (!target_distance_from_origin || target_distance_from_origin > current_distance + distance_to_target_from_here)
        set_distance(neighbour, current_distance + distance_to_target_from_here)
        calculates_paths_from << neighbour
      end
    end

    # Because its so satisfying !
    # print_matrix(distance_matrix)
    # puts "-" * ELEM_OUTPUT_SIZE * (map_width + 1)
    # sleep(0.1)
    # Calculate shortest paths from node that have been modified
    calculates_paths_from.each do |updated_neighbour|
      shortest_paths_from(updated_neighbour)
    end
  end

  def height(node) = height_map[node.y][node.x]

  def distance(node) = distance_matrix[node.y][node.x]

  def set_distance(node, distance)
    distance_matrix[node.y][node.x] = distance
  end

  # id node in arg in the map ?
  def in_map?(node)
    (0...map_width).cover?(node.x) && (0...map_height).cover?(node.y)
  end

  def problem_1
    shortest_paths_from(origin)
    # print_matrix(distance_matrix)
    distance(destination)
  end

  def problem_2
    a_nodes = height_map.each_with_index.flat_map do |row, y|
      row.each_with_index.map do |height, x|
        # 'a' is height 97
        height == 97 ? Node.new(x, y) : nil
      end
    end.compact
    # Set all a at 0 and run the algorithm from all a to avoid having separated regions not detected correctly
    a_nodes.each { set_distance(_1, 0) }
    a_nodes.each { shortest_paths_from(_1) }
    puts "result: #{distance(destination)}"
    distance(destination)
  end

  def print_matrix(matrix)
    output_string = matrix.map do |row|
      row.map do |value|
        value ? value.to_s.center(ELEM_OUTPUT_SIZE) : ".".center(ELEM_OUTPUT_SIZE)
      end.join(" ")
    end.join("\n")

    puts output_string
  end
end
