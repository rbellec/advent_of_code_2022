class Day04
  TEST_DATA = %w[
    2-4,6-8
    2-3,4-5
    5-7,7-9
    2-8,3-7
    6-6,4-6
    2-6,4-8
  ]

  def self.call
    new.problem_2
  end

  attr_reader :lines, :ranges

  def initialize
    # @lines = TEST_DATA
    @lines = DataReader.new(day: 4).content
    @ranges = @lines.map(&method(:read_sections))
  end

  def problem_1
    ranges.count do |elve1_sections, elve2_sections|
      elve1_sections.cover?(elve2_sections) || elve2_sections.cover?(elve1_sections)
    end
  end

  def problem_2
    ranges.count do |elve1_sections, elve2_sections|
      elve1_sections.overlaps?(elve2_sections)
    end
  end

  def read_sections(line)
    # not in the mood for regexp or treetop today
    line.split(",").map { Range.new(* _1.split("-").map(&:to_i)) }
  end
end
