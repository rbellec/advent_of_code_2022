require "pp"
require "polyglot"
require "treetop"
require "byebug"

# This file was used to iterate on test & creating parser. I'll work on an article about this.

Treetop.load "day_19_grammar"

TEST_DATA = <<~DATA
  Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.

  Blueprint 2:
    Each ore robot costs 2 ore.
    Each clay robot costs 3 ore.
    Each obsidian robot costs 3 ore and 8 clay.
    Each geode robot costs 3 ore and 12 obsidian.
DATA

def test(name, bool_value)
  print(bool_value ? " . " : "error #{name}")
end

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

def test_parse_problem_file
  text = File.read("../../../problems_data/data_day_19_1.txt")
  parser = BluePrintsParser.new
  pp parser.parse(text).blueprints
end

test_parsers
test_parsers_return_values
test_parse_problem_file
