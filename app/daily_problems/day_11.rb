class Day11
  extend DailyProblemHelpers

  TEST_DATA_1 = <<~DATA
    Monkey 0:
      Starting items: 79, 98
      Operation: new = old * 19
      Test: divisible by 23
        If true: throw to monkey 2
        If false: throw to monkey 3

    Monkey 1:
      Starting items: 54, 65, 75, 74
      Operation: new = old + 6
      Test: divisible by 19
        If true: throw to monkey 2
        If false: throw to monkey 0

    Monkey 2:
      Starting items: 79, 60, 97
      Operation: new = old * old
      Test: divisible by 13
        If true: throw to monkey 1
        If false: throw to monkey 3

    Monkey 3:
      Starting items: 74
      Operation: new = old + 3
      Test: divisible by 17
        If true: throw to monkey 0
        If false: throw to monkey 1

  DATA

  TEST_DATA_2 = <<~DATA
    .
  DATA

  TEST_DATA = TEST_DATA_1

  def self.call(dataset: :test)
    day_solver = new(open_dataset(dataset: dataset))
    day_solver.problem_1
  end

  def initialize(data_stream)
    # @monkeys = []
    read(data_stream)
  end

  # Operation: new = old * old
  # Test: divisible by 13
  #   If true: throw to monkey 1
  #   If false: throw to monkey 3

  def read(stream)
    @monkeys = []
    stream.each_line do |line|
      case line.chomp!
      when /^Monkey (\d+):/
        @monkeys << Monkey.new($1.to_i)
      when /Starting items: (.+)$/
        @monkeys.last.worry_levels = $1.split(",").map(&:strip).map(&:to_i)
      when /Operation: new = (.+)/
        @monkeys.last.operation = $1.strip
      when /Test: divisible by (\d+)/
        @monkeys.last.test_divisible_by = $1.to_i
      when /If true: throw to monkey (\d+)/
        @monkeys.last.recipient_when_test_succeed = $1.to_i
      when /If false: throw to monkey (\d+)/
        @monkeys.last.recipient_when_test_fail = $1.to_i
        # else
        # puts "Line not interpreted: #{line}"
      end
    end
  end

  def problem_1
    20.times do |i|
      inspection_round
      puts "After round %3d, the monkeys are holding items with these worry levels:" % i
      puts monkeys.map(&:to_s).join("\n")
    end
  end

  def problem_2
  end

  def inspection_round
    monkeys.each do |monkey|
      monkey_actions = monkey.inspection

      # Monkey throw all items
      monkey.clear_items

      # Reattribute items
      monkey_actions.each do |recipient, worry_level|
        monkeys[recipient].add_item(worry_level)
      end
    end
  end

  class Monkey
    def initialize(number)
      @number = number
      @worry_levels = []
    end

    def clear_items
      @worry_levels = []
    end

    def add_item(worry_level)
      worry_levels << worry_level
    end

    # Return an array of pairs
    # [
    #   [recipient, item worry level]
    #   ...
    # ]
    def inspection
      new_item_worry_levels = worry_levels
        .map { execute_operation(_1) }
        .map { _1 / 3 }
      recipients = new_item_worry_levels.map { recipient_monkey(_1) }
      recipients.zip(new_item_worry_levels)
    end

    def recipient_monkey(item_worry_level)
      if item_worry_level % test_divisible_by == 0
        recipient_when_test_succeed
      else
        recipient_when_test_fail
      end
    end

    def execute_operation(item_worry_level)
      operation_elements = /(old|\d+) (.) (old|\d+)/.match(operation)
      l_value = operation_elements[1] == "old" ? item_worry_level : operation_elements[1].to_i
      operator = operation_elements[2]
      r_value = operation_elements[3] == "old" ? item_worry_level : operation_elements[3].to_i

      case operator
      when "+"
        l_value + r_value
      when "*"
        l_value * r_value
      else
        puts "Unknown operator: #{operator}"
      end
    end

    def to_s
      "Monkey: %2d: %s" % [number, worry_levels.join(", ")]
    end

    attr_reader :number
    attr_accessor :worry_levels, :operation, :test_divisible_by, :recipient_when_test_succeed, :recipient_when_test_fail
  end

  attr_reader :monkeys
end
