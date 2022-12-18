class Day17
  extend DailyProblemHelpers

  TEST_DATA = ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>"

  def self.call(problem = false)
    dataset = problem ? :problem : :test
    day_solver = new(open_dataset(dataset: dataset))
    day_solver.problem_1
  end

  def initialize(data_stream)
    @chamber_width = 7
    # Each rock appears so that its left edge is two units away from the left wall and its bottom edge is three
    # units above the highest rock in the room (or the floor, if there isn't one).
    @initial_x = 2
    @initial_y_delta = 3
    read(data_stream)
  end

  def read(stream)
    # Only 1 line today
    @jet_streams = stream.gets.chomp!.chars
  end

  def problem_1

  end

  def problem_2
  end

  # attr_reader :
end
