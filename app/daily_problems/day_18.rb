class Day18
  extend DailyProblemHelpers

  TEST_DATA = <<~DATA
    2,2,2
    1,2,2
    3,2,2
    2,1,2
    2,3,2
    2,2,1
    2,2,3
    2,2,4
    2,2,6
    1,2,5
    3,2,5
    2,1,5
    2,3,5
  DATA

  class Cube
    DIRECTIONS = [Vector[1, 0, 0], Vector[0, 1, 0], Vector[0, 0, 1],
      Vector[-1, 0, 0], Vector[0, -1, 0], Vector[0, 0, -1]]

    # All cubes are 1x1x1 cubes
    attr_reader :coords

    def initialize(vector_coords)
      # Test Matrix lib
      @coords = vector_coords
    end

    def x = coords[0]

    def y = coords[1]

    def z = coords[2]

    def adjacent_cubes = DIRECTIONS.map { Cube.new(coords + _1) }

    delegate :hash, to: :coords

    # def hash = coords.to_a.join(":").hash

    def ==(other) = coords == other.coords
    alias_method :eql?, :==
    def to_s(size = 3) = "(%#{size}d, %#{size}d, %#{size}d)" % coords.to_a
  end

  def self.call(level = 1, problem = false)
    dataset = problem ? :problem : :test
    day_solver = new(open_dataset(dataset: dataset))
    case level
    when 1
      day_solver.problem_1
    when 2
      day_solver.problem_2
    end
  end

  def initialize(data_stream)
    read(data_stream)
  end

  def read(stream)
    @cubes = stream.each_line.map do |line|
      line.chomp!
      coords = Vector.elements(line.split(",").map(&:to_i))
      Cube.new(coords)
    end
    @cube_set = Set.new(@cubes)
  end

  def problem_1
    # First draft: for each cure, compute the number of non immediatly obtructed faces.
    # Works only on plain (no holes inside) convex and non convex structures.
    # Works in current case.
    cubes_faces_count = @cubes.map { [_1, 0] }.to_h
    @cubes.each do |cube|
      cubes_faces_count[cube] = cube.adjacent_cubes.count { |c| !cubes_faces_count.has_key?(c) }
    end

    cubes_faces_count.values.sum
  end

  def problem_2
    # Try first all visible faces from 6 directions. Work only on convex volumes.
    # Not working on example. Other idea : mark all visible faces of cubes, then walk on adjascent visible faces.
    # Finally saw an animation of a flooding algo. This is an attempt I prefere to try doing it before seing
    # proper implementation online.
    #

    x_min, x_max = cube_set.map(&:x).minmax
    y_min, y_max = cube_set.map(&:y).minmax
    z_min, z_max = cube_set.map(&:z).minmax

    x_min -= 1
    x_max += 1
    y_min -= 1
    y_max += 1
    z_min -= 1
    z_max += 1

    # Create firt layer of flooding cubes
    flooding_cubes = (x_min..x_max).to_a.product((y_min..y_max).to_a).map do |x, y|
      Cube.new(Vector[x, y, z_min])
    end.to_set

    flooding_cubes_previous_cardinal = 0
    while flooding_cubes_previous_cardinal != flooding_cubes.size
      flooding_cubes_previous_cardinal = flooding_cubes.size
      added_cubes = flooding_cubes.flat_map { _1.adjacent_cubes }.filter do |cube|
        # Check if created cube is in boundaries.
        (x_min..x_max).cover?(cube.x) && (y_min..y_max).cover?(cube.y) && (z_min..z_max).cover?(cube.z)
      end
      flooding_cubes.merge(added_cubes)
      flooding_cubes -= cube_set
    end

    # Number of visible face is the sum of, for each cube of flooding cube set, the number of adjacent_cubes
    # which are in the droplet
    flooding_cubes.map do |flood_cube|
      flood_cube.adjacent_cubes.count { cube_set.include?(_1) }
    end.sum
  end

  attr_reader :cubes, :cube_set
end
