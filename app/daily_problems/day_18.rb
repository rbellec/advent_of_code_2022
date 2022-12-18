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

    def adjascent_cubes = DIRECTIONS.map { new(coords + _1) }

    def hash = coords.to_a.join(":").hash

    def ==(other) = coords == other.coords
    alias_method :eql?, :==
    def to_s(size = 3) = "(%#{size}d, %#{size}d, %#{size}d)" % coords.to_a
  end

  def self.call(problem = false)
    dataset = problem ? :problem : :test
    day_solver = new(open_dataset(dataset: dataset))
    day_solver.problem_1
  end

  def initialize(data_stream)
    read(data_stream)
  end

  def read(stream)
    @cubes = stream.each_line.map do |line|
      line.chomp!
      Vector.elements(line.split(",").map(&:to_i))
    end
  end

  def problem_1
    # First draft: compute visible faces, which works only on convex structures.

    self
  end

  def problem_2
  end

  # attr_reader :
end
