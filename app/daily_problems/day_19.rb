# I promised to explain how to code parser with Treetop to some friends.
# I have no idea yet on how to solve this problem, but I'll first use it to explain
# my workflow. I'll do it in this file, this is not a blog post or a full app, but
# it should be clear enough.

# You will find the treetop parser in the `day_19_grammar.treetop` file.
require "day_19_grammar"

# Let's do all treetop work in this class to avoid polluting
class Day19
  extend DailyProblemHelpers

  # 1 First I write a first grammar draft that allows me to consider all rules and sub rules. This is generally NOT working.
  #
  # Treetop parsers may be difficult do debug, which is why I decide, after this first draft
  # to immediately work in TDD/BDD (test driven development or similar methods) for the simplest rules.
  # I'll do it in the code here, but obviously we would use a dedicated framework in a real project (rspec, minitest...)

  class ParsersTests
    def self.test(name, bool_value)
      puts (bool_value ? "." : "error #{name}")
    end

    def self.test_parsers
      # You can call a specific rule using the root: parameter
      # First focus on parser and leave ruby codes (rules actions) aside. It's much faster to have a running parser then extract what you need
      # I won't all terminal rules here, but believe me, you have to do it in unit tests. The day your "spaces" (`sp` here) parser does not work,
      # (mistyping inside or any stupid bug) you can spend lot of time understanding why your parser does not work anymore.
      results = []
      parser = BluePrintsParser.new

      # in rspec: expect(parser.parse("10", root: :number)).not_to be_nil
      test "number", parser.parse("10", root: :number)
      test "material", parser.parse("clay", root: :material)
      ["10 clay", "5 ore", "12 obsidian"].each do |test_string|
        test "cost", parser.parse(test_string, root: :cost)
      end
      test "robot_cost", parser.parse("Each ore robot costs 4 ore.", root: :robot_cost)
      test "robot_costs", parser.parse("Each geode robot costs 2 ore and 7 obsidian.", root: :robot_cost)
      test "blueprint", parser.parse("Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.", root: :blueprint)
      test "blueprints", parser.parse(Day19::TEST_DATA, root: :blueprints)
      puts results.join(" ")
    end

    # Once I am sure the parsers are working correctly, I work on their individual return values.
    # This is the moment I start to add methods to parser rules. Avoid method with the same name as subrule !
    def self.test_parsers_return_values
      # Simulate a test framework
      def ptest(name, bool_value)
        puts (bool_value ? "." : "error #{name}")
      end

      # require "day_19_grammar"
      parser = BluePrintsParser.new
      r=parser.parse("10 clay", root: :cost)
      # Same, this would be simpler with a real test framework
      ptest("cost return value", parser.parse("10 clay", root: :cost).cost_hash == {clay: 10})
      # test "robot definition", parser.parse("Each ore robot costs 4 ore.", root: :robot_cost) == {collect: :ore, cost:[{clay: 10}]}
      # results += ["", "5 ore", "12 obsidian"].map{parser.parse(_1, root: :cost) ? "." : "error material"}
      # results << (parser.parse("Each ore robot costs 4 ore.", root: :robot_cost) ? "." : "error robot_cost")
      # results << (parser.parse("Each geode robot costs 2 ore and 7 obsidian.", root: :robot_cost) ? "." : "error robot_cost")
      # results << (parser.parse("Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.", root: :blueprint) ? "." : "error blueprint")
      # results << (parser.parse(Day19::TEST_DATA, root: :blueprints) ? "." : "error blueprints")
      puts results.join(" ")
    end
  end


  TEST_DATA = <<~DATA
    Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
    Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.
  DATA

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
    Treetop.load "day_19_grammar"
    # I wanted to use treetop to show this to some colleagues.
    # Treetop can be difficult to debug, I would higly recommand to set up unit tests
    # for each parser rule. Example:
    # ```
    # result = parser.parse('3 ore', root: :cost)
    # expect(result).to ...

    # stream.each_line do |line|
    #   case line.chomp!
    #   when /.../
    #   else      end
    # end
  end

  def problem_1
  end

  def problem_2
  end

  # attr_reader :
end
