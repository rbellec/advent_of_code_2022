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

    def adjascent_cubes = DIRECTIONS.map { Cube.new(coords + _1) }

    def hash = coords.to_a.join(":").hash

    def ==(other) = coords == other.coords
    alias_method :eql?, :==
    def to_s(size = 3) = "(%#{size}d, %#{size}d, %#{size}d)" % coords.to_a
  end

  def self.call(problem = false)
    dataset = problem ? :problem : :test
    day_solver = new(open_dataset(dataset: dataset))
    day_solver.problem_2
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
  end

  def problem_1
    # First draft: for each cure, compute the number of non immediatly obtructed faces.
    # Works only on plain (no holes inside) convex and non convex structures.
    # Works in current case.
    cubes_faces_count = @cubes.map { [_1, 0] }.to_h
    @cubes.each do |cube|
      cubes_faces_count[cube] = cube.adjascent_cubes.count { |c| !cubes_faces_count.has_key?(c) }
    end

    cubes_faces_count.values.sum
  end

  def problem_2
    # Try first all visible faces from 6 directions. Work only on convex volumes.
    # Not working on example. Other idea : mark all visible faces of cubes, then walk on adjascent visible faces.
    # No time to try it now.
    x_sorted_cubes = @cubes.sort_by(&:x)
    y_sorted_cubes = @cubes.sort_by(&:y)
    z_sorted_cubes = @cubes.sort_by(&:z)

    x_proj = Matrix.diagonal(0, 1,1)
    y_proj = Matrix.diagonal(1,0,1)
    z_proj = Matrix.diagonal(1,1,0)

    visible_z_up = z_sorted_cubes.map{|c| Vector[0,0,1] + z_proj * c.coords}
    visible_z_down = z_sorted_cubes.reverse.map{|c| Vector[0,0,-1] + z_proj * c.coords}

    visible_x_up = x_sorted_cubes.map{|c| Vector[1,0,0] + x_proj * c.coords}
    visible_x_down = x_sorted_cubes.reverse.map{|c| Vector[-1,0,0] + x_proj * c.coords}

    visible_y_up = y_sorted_cubes.map{|c| Vector[0,1,0] + y_proj * c.coords}
    visible_y_down = y_sorted_cubes.reverse.map{|c| Vector[0,-1,0] + y_proj * c.coords}

    visible_faces = Set.new()
    [visible_z_up, visible_z_down, visible_x_up, visible_x_down, visible_y_up, visible_y_down].each{visible_faces.merge(_1)}
    visible_faces

  end

  attr_reader :cubes
end
