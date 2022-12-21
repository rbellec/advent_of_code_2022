# # How to write a treetop parser II
# I just follow the same process as described in Day 19

require "pp"
require "treetop"
require "byebug"

# Load the grammar
Treetop.load "day_21_grammar"

# Keep sample data, I try to keep different forms of text to avoid the trap of parsing only one. Here the differences are spaces only.

TEST_DATA = <<~DATA
  root: pppw + sjmn
  dbpl: 5
  ptdq: humn - dvpt
  ptdq: humn / dvpt
  ptdq: humn * dvpt
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
  parser = MonkeysMathParser.new

  # in rspec: expect(parser.parse("10", root: :number)).not_to be_nil
  test "number", parser.parse("10", root: :number)
  test "name", parser.parse("pppw", root: :name)

  ["pppw + sjmn", "pppw - sjmn", "pppw * sjmn", "pppw / sjmn"].each do |test_string|
    test "operation", parser.parse(test_string, root: :operation)
  end

  a = parser.parse("root: pppw + sjmn", root: :monkey)
  byebug
  test "monkey_1", parser.parse("root: pppw + sjmn", root: :monkey)
  test "monkey_2", parser.parse("dbpl: 5", root: :monkey)
  puts "end"
end

# Now you are confident your parser is working on some test data. This is the time to build result values (AST or anything you need).
# This is also an iterative process where I like to stay free of the final representation while I move to more complex parsers.
# I often decide to change sub rules representations of result and iterate while writing theses tests.
# Note that I have not done enough parser to find a proper convention for rules added methods names. As much as I do not like the
# repetition of words, this is what I ended with. Also I sometimes do not undersand why I can not access text_values in terminal rules and
# did not spend enough time on this yet, you will find that `number` rules result here has to be handled in above rules.

def test_parsers_return_values
  parser = MonkeysMathParser.new

  # in rspec: expect(parser.parse("10", root: :number)).not_to be_nil
  test "number", parser.parse("10", root: :number)
  test("name", parser.parse("pppw", root: :name).text_value == "pppw")

  test("operation",
    parser.parse("pppw + sjmn", root: :operation).operation == {operator: "+", lhs: "pppw", rhs: "sjmn"})

  test("monkey",
    parser.parse("root: pppw + sjmn", root: :monkey).monkey == ["root", {operator: "+", lhs: "pppw", rhs: "sjmn"}])

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
# test_parse_problem_file
