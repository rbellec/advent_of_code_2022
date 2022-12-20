# I promised to explain how to code parser with Treetop to some friends.
# I have no idea yet on how to solve this problem, but I'll first use it to explain
# my treetop workflow. I'll do it in this file and related test file, this is not a blog post (yet)
# or a full app, but it should be clear enough (hopefully).

# You will find the treetop parser in the `grammars/day_19_grammar.treetop` file and the explanation in
# `build_treetop_parser_workflow.rb`

class Day19
  extend DailyProblemHelpers

  TEST_DATA = <<~DATA
    Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
    Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.
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
    grammar_file = Rails.root.join("app/daily_problems/grammars/day_19_grammar.treetop")
    Treetop.load grammar_file.to_s

    text_definition = stream.read
    @blueprints = BluePrintsParser.new.parse(text_definition).blueprints
  end

  # Let's build possible paths to create one robot
  def path_to_build(blueprint, robot)
    # costs = blueprint[robot]

    # If you need 7 obsidian ans 2 ore to build a geode robot, the longest time (once you have at least one of each) will be 7 minutes.
    # longest_cost = costs.values.max

    # Let's iterate on "cost duration" to build path do build this robot asap.
    # (1..longest_cost).map
    # sub_robot_paths =
  end

  def robot_state_per_minute(blueprint, max_minutes, status)
  end

  # Let's have a visual representation of this
  def blueprint_equations(blueprint)
    costs = blueprint[:definition]
    costs.map do |robot, ressources|
      "#{robot}_robot = " + ressources.map { |ressource, cost| cost.to_s + "." + ressource.to_s }.join(" + ")
    end.join("\n")
  end

  def problem_1
    # I initially thought it could be a Linear proramming problem and... I spent too much time on writing the treetop parser example !
    # I am not sure it's a flow or LP problem anymore... And will try to solve it analysing shortest paths to create geode robots.
    # To reduce state space I'll try to take the problem from geode robots. The score is basically the number
    # of geode robots * number of minute they run. For each blue print lets find the path to build a geode robot.
    puts blueprint_equations(@blueprints.first.last)
    # Score is number of geode robots
  end

  def problem_2
  end

  attr_reader :blueprints
end
