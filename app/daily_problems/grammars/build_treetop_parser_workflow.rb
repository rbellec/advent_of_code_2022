# # How to write a treetop parser
# 1 First I write a first grammar draft that allows me to consider all rules and sub rules. This is generally NOT working.
# 2 TDD starting with simplest rules. The first goal is just to have the parser works on input data, we will address building result values later.
# 3 Once all rules works and have tests, I start to write an other set of test to work on rules return values.
#
# The whole process is very iterative and well adapted to TDD. Please ALWAYS keep unit tests for simplest terminal rules. I already (after a miss click)
# had an unwanted char in the "space" `sp` rule and you cal loose hours trying to understand why your parser fails in this strange way.

# In current case I'll show the workflow using a simple `test` method.
# Treetop parsers may be difficult do debug, which is why, after this first draft. A dedicated framework & tooling (rspec, minitest...) should obviously be used in a real project.

# And yes, `pp` and debugger can help you develop faster this king of code.
require "pp"
require "treetop"
require "byebug"

# Load the grammar
Treetop.load "day_19_grammar"

# Keep sample data, I try to keep different forms of text to avoid the trap of parsing only one. Here the differences are spaces only.
TEST_DATA = <<~DATA
  Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.

  Blueprint 2:
    Each ore robot costs 2 ore.
    Each clay robot costs 3 ore.
    Each obsidian robot costs 3 ore and 8 clay.
    Each geode robot costs 3 ore and 12 obsidian.
DATA

# Test framework used for this article :)
def test(name, bool_value)
  print(bool_value ? " . " : "error #{name}")
end

# First parser tests. The goal here is to test one by one, starting with the simplest, all rules.
# a simple rule not working as expected can be difficult to test from more complex ones. TDD is perfect to
# speed up this kind of development. You have here the full tests, but I generally work this way:
# 1. Write one general test for the rule. Just check it parses input.
# 2. make it works eventually using debugger or output
# 3. write multiple cases for this rule. You will find only one rule here with multiple cases.

def test_parsers
  parser = BluePrintsParser.new

  # in rspec: expect(parser.parse("10", root: :number)).not_to be_nil
  test "number", parser.parse("10", root: :number)
  test "material", parser.parse("clay", root: :material)
  ["10 clay", "5 ore", "12 obsidian"].each do |test_string|
    test "cost", parser.parse(test_string, root: :cost)
  end
  test "robot_cost", parser.parse("Each ore robot costs 4 ore.", root: :robot_blueprint)
  test "robot_costs", parser.parse("Each geode robot costs 2 ore and 7 obsidian.", root: :robot_blueprint)
  test "blueprint", parser.parse("Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.", root: :blueprint)
  test "blueprints", parser.parse(TEST_DATA, root: :blueprints)
  puts "end"
end

# Now you are confident your parser is working on some test data. This is the time to build result values (AST or anything you need).
# This is also an iterative process where I like to stay free of the final representation while I move to more complex parsers.
# I often decide to change sub rules representations of result and iterate while writing theses tests.
# Note that I have not done enough parser to find a proper convention for rules added methods names. As much as I do not like the
# repetition of words, this is what I ended with. Also I sometimes do not undersand why I can not access text_values in terminal rules and
# did not spend enough time on this yet, you will find that `number` rules result here has to be handled in above rules.

def test_parsers_return_values
  parser = BluePrintsParser.new

  test "cost return value", parser.parse("10 clay", root: :cost).cost_hash == {clay: 10}
  test "robot definition", parser.parse("Each ore robot costs 4 ore.", root: :robot_blueprint).robot_blueprint == {ore: {ore: 4}}
  test "robot definition", parser.parse("Each geode robot costs 2 ore and 7 obsidian.", root: :robot_blueprint).robot_blueprint == {geode: {ore: 2, obsidian: 7}}
  test(
    "single blueprint",
    parser.parse("Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.", root: :blueprint).blueprint ==
      {blueprint: 2, definition: {ore: {ore: 2}, clay: {ore: 3}, obsidian: {ore: 3, clay: 8}, geode: {ore: 3, obsidian: 12}}}
  )

  # pp parser.parse(TEST_DATA, root: :blueprints).blueprints
  puts "end rv"
end

# Then I try to parse the whole file and check it works and give a usable result.
def test_parse_problem_file
  text = File.read("../../../problems_data/data_day_19_1.txt")
  parser = BluePrintsParser.new
  pp parser.parse(text).blueprints
end

test_parsers
test_parsers_return_values
test_parse_problem_file
