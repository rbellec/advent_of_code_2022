class #DailyClassName
  extend DailyProblemHelpers

  TEST_DATA_1 = <<~DATA
    .
  DATA

  TEST_DATA_2 = <<~DATA
    .
  DATA

  TEST_DATA = TEST_DATA_1

  def self.call(level=1,problem = false)
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
    stream.each_line do |line|
      case line.chomp!
      when /.../
      else      end
    end
  end

  def problem_1
  end

  def problem_2
  end

  # attr_reader :
end
