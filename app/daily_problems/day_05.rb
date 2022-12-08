class Day05
  TEST_DATA = <<~DATA
        [D]
    [N] [C]
    [Z] [M] [P]
     1   2   3
    
    move 1 from 2 to 1
    move 3 from 1 to 3
    move 2 from 2 to 1
    move 1 from 1 to 2
  DATA

  def self.call
    d = new
    d.print_stacks
    puts ("--- " * d.stacks.size) + "\n\n"
    puts "top crates: " + d.problem_2
    puts ""
    d.print_stacks
    puts ("--- " * d.stacks.size) + "\n\n"
  end

  attr_reader :lines, :stacks, :instructions

  def initialize
    # @lines = TEST_DATA.split("\n")
    @lines = DataReader.new(day: 5).content
    read_input(@lines)
  end

  def problem_1
    @instructions.each { |i| execute_crate_mover_9000(instruction: i) }
    @stacks.map(&:first).join("")
  end

  def problem_2
    @instructions.each { |i| execute_crate_mover_9001_with_extra_cup_holder(instruction: i) }
    @stacks.map(&:first).join("")
  end

  def execute_crate_mover_9000(instruction:)
    from = instruction[:from] - 1
    to = instruction[:to] - 1

    instruction[:number].times do
      crate = @stacks[from].shift
      @stacks[to].unshift(crate) if crate
    end
  end

  def execute_crate_mover_9001_with_extra_cup_holder(instruction:)
    # This side effect in this method has been requested by CrateMover 9001 sales & marketing team
    # Don't mind the noise on console, this is fundamental part of suceeding in finishing AOC and motivating
    # Elves.
    puts "Congratulations for using the new CrateMover 9001 with air conditioning, leather seats, an extra cup holder."

    from = instruction[:from] - 1
    to = instruction[:to] - 1

    crates = @stacks[from].shift(instruction[:number])
    @stacks[to].unshift(*crates)
  end

  def read_input(lines)
    stacks_lines, separator, instructions_lines = lines.chunk { |line| !line.empty? }.map(&:last)
    @stacks = read_stacks(stacks_lines)
    @instructions = read_instructions(instructions_lines)
  end

  def read_stacks(lines)
    # Keep line with stack names
    content = lines.map { |l| l.scan(/.(.). ?/).flatten }
    stack_numbers = content.map(&:size).max
    stacks = stack_numbers.times.map { [] }

    # Keep stack numbers somewhere in cas pb 2 mixes them
    @stack_names = content.pop

    # Fill stacks
    content.each do |stack_line|
      stack_line.each_with_index do |item, stack_index|
        unless item.blank?
          stacks[stack_index].push(item)
        end
      end
    end

    stacks
  end

  def read_instructions(instructions_lines)
    instructions_lines.map do |line|
      matchdata = /move (\d+) from (\d) to (\d)/.match(line)
      {number: matchdata[1].to_i, from: matchdata[2].to_i, to: matchdata[3].to_i} if matchdata
    end.compact
  end

  def print_stacks
    # Use destructive algo on a copy of all stacks
    highest = @stacks.map(&:size).max
    stacks = @stacks.map(&:dup)

    lines = highest.times.map do
      stacks.map do |stack|
        item = stack.pop
        item.nil? ? "   " : "[#{item}]"
      end.join(" ")
    end.reverse

    lines.each { |line| puts line }
    lines
  end
end
