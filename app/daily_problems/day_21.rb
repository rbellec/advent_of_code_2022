class Day21
  extend DailyProblemHelpers

  def monkey_value(name)
    raise("Asking a non exitent monkey. They all scream together incoherent numbers") if !monkey_definitions.has_key?(name)

    monkey = monkey_definitions[name]
    return monkey[:value] if monkey[:value]

    # Note : value memoisation removed for problem 2

    raise("Monkey error, throwing barrels everywhere in tribute to donkey kong") unless monkey[:type] == :operation

    # Not: infinite loop in case of cycles in monkey definitions.
    case monkey[:operator]
    when "+"
      monkey_value(monkey[:lhs]) + monkey_value(monkey[:rhs])
    when "-"
      monkey_value(monkey[:lhs]) - monkey_value(monkey[:rhs])
    when "*"
      monkey_value(monkey[:lhs]) * monkey_value(monkey[:rhs])
    when "/"
      # I don't know what monkey could do in case of a divide by zero and I am not sure I would like to !
      monkey_value(monkey[:lhs]) / monkey_value(monkey[:rhs])
    end
  end

  # I initially prepared a up/down solver on an operation tree before hearing "With complex numbers..."

  def problem_1
    monkey_value("root")
  end

  def problem_2
    monkey_definitions["humn"][:value] = Complex(0, 1)
    root = monkey_definitions["root"]
    rhs = monkey_value(root[:rhs])
    lhs = monkey_value(root[:lhs])

    if rhs.is_a? Complex
      real = lhs
      complex = rhs
    else
      real = rhs
      complex = lhs
    end

    # Solution
    (real - complex.real) / complex.imaginary
  end

  TEST_DATA = <<~DATA
    root: pppw + sjmn
    dbpl: 5
    cczh: sllz + lgvd
    zczc: 2
    ptdq: humn - dvpt
    dvpt: 3
    lfqf: 4
    humn: 5
    ljgn: 2
    sjmn: drzm * dbpl
    sllz: 4
    pppw: cczh / lfqf
    lgvd: ljgn * ptdq
    drzm: hmdt - zczc
    hmdt: 32
  DATA

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
    @monkey_definitions = stream.each_line.each_with_index.map do |line, index|
      case line.chomp!
      when /(\w+): (\d+)/
        [$1, {type: :scream, value: $2.to_i, num: index + 1}] # Why do I think we will need monkey index ?
      when /(\w+): (\w+) ([+\-*\/]) (\w+)/
        [$1, {type: :operation, lhs: $2, operator: $3, rhs: $4, value: nil, num: index + 1}] # Why do I think we will need monkey index ?
      else
        puts "Line not matched."
      end
    end.to_h
  end

  attr_reader :monkey_definitions
end
