class Day10
  extend DailyProblemHelpers

  TEST_DATA_1 = <<~DATA
    noop
    addx 3
    addx -5
  DATA

  TEST_DATA_2 = <<~DATA
    addx 15
    addx -11
    addx 6
    addx -3
    addx 5
    addx -1
    addx -8
    addx 13
    addx 4
    noop
    addx -1
    addx 5
    addx -1
    addx 5
    addx -1
    addx 5
    addx -1
    addx 5
    addx -1
    addx -35
    addx 1
    addx 24
    addx -19
    addx 1
    addx 16
    addx -11
    noop
    noop
    addx 21
    addx -15
    noop
    noop
    addx -3
    addx 9
    addx 1
    addx -3
    addx 8
    addx 1
    addx 5
    noop
    noop
    noop
    noop
    noop
    addx -36
    noop
    addx 1
    addx 7
    noop
    noop
    noop
    addx 2
    addx 6
    noop
    noop
    noop
    noop
    noop
    addx 1
    noop
    noop
    addx 7
    addx 1
    noop
    addx -13
    addx 13
    addx 7
    noop
    addx 1
    addx -33
    noop
    noop
    noop
    addx 2
    noop
    noop
    noop
    addx 8
    noop
    addx -1
    addx 2
    addx 1
    noop
    addx 17
    addx -9
    addx 1
    addx 1
    addx -3
    addx 11
    noop
    noop
    addx 1
    noop
    addx 1
    noop
    noop
    addx -13
    addx -19
    addx 1
    addx 3
    addx 26
    addx -30
    addx 12
    addx -1
    addx 3
    addx 1
    noop
    noop
    noop
    addx -9
    addx 18
    addx 1
    addx 2
    noop
    noop
    addx 9
    noop
    noop
    noop
    addx -1
    addx 2
    addx -37
    addx 1
    addx 3
    noop
    addx 15
    addx -21
    addx 22
    addx -6
    addx 1
    noop
    addx 2
    addx 1
    noop
    addx -10
    noop
    noop
    addx 20
    addx 1
    addx 2
    addx 2
    addx -6
    addx -11
    noop
    noop
    noop
  DATA

  TEST_DATA = TEST_DATA_2

  def self.call(dataset: :test)
    solver = new(open_dataset(dataset: dataset))
    solver.problem_1
  end

  def initialize(data_stream)
    read_and_interpret(data_stream)
  end

  def read_and_interpret(stream)
    format = "%4d: %5d  %s"
    register = 1
    cycle_num = 1
    @cycles = []
    @logs = []
    stream.each_line do |line|
      case line.chomp!
      when /noop/
        @cycles.push(register)
        @logs.push(format % [cycle_num, register, line])
        cycle_num += 1
      when /addx (-?\d+)/
        @cycles.push(register, register)
        @logs.push(format % [cycle_num, register, line])
        @logs.push(format % [cycle_num + 1, register, ""])
        cycle_num += 2
        register += $1.to_i
      end
    end
  end

  def problem_1
    puts @logs.join("\n")
    ticks = [20, 60, 100, 140, 180, 220]
    ticks.zip(ticks.map { cycles[_1 - 1] }).map { |a, b| a * b }.sum
  end

  def problem_2
    screen = Array.new(6) { Array.new(40) }
    @cycles.each_with_index do |register, tick|
      row = tick / 40
      col = tick % 40
      pixel = (register - 1..register + 1).cover?(col) ? "#" : " "
      screen[row][col] = pixel
    end
    puts screen.map(&:join).join("\n")
  end

  attr_reader :cycles
end
