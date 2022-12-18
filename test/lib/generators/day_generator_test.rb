require "test_helper"
require "generators/day/day_generator"

class DayGeneratorTest < Rails::Generators::TestCase
  tests DayGenerator
  destination Rails.root.join('tmp/generators')
  setup :prepare_destination

  # test "generator runs without errors" do
  #   assert_nothing_raised do
  #     run_generator ["arguments"]
  #   end
  # end
end
