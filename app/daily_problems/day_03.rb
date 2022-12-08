class Day03
  TEST_DATA = %w[
    vJrwpWtwJgWrhcsFMMfFFhFp
    jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
    PmmdzqPrVvPwwTWBwg

    wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
    ttgJtRGJQctTZtZT
    CrZsJsPPZsGzwwsLwLmpwMDw
  ]

  def self.call
    new.problem_2
  end

  attr_reader :lines

  def initialize
    # @lines = TEST_DATA
    @lines = DataReader.new(day: 3, problem: 1).content
  end

  def problem_1
    lines.map do |line|
      priority_for(Rucksack.new(line).get_duplicate)
    end.sum
  end

  def problem_2
    # Could continue with duplicate detection, but I like sets
    bags = lines.map { |l| Rucksack.new(l) }
    badges = bags
      .map(&:item_set)
      .each_slice(3)
      .map { |bag1, bag2, bag3| (bag1 & bag2 & bag3).first } # badge for each group of 3
      .map(&method(:priority_for))
      .sum
  end

  def priority_for(letter)
    case letter
    when /[a-z]/
      letter.ord - "a".ord + 1
    when /[A-Z]/
      letter.ord - "A".ord + 27
    end
  end

  class Rucksack
    attr_reader :content, :compartments, :str_compartments, :item_set

    def initialize(line)
      @items = line.split("")
      @compartments = @items.each_slice(line.size / 2).to_a
      @str_compartments = @compartments.map(&:join)
      @item_set = Set.new(@items)
    end

    # Could do a simple o(n^2) match... But creating a regexp is more fun !
    def get_duplicate
      Regexp.new("[#{@str_compartments.first}]").match(@str_compartments.last)[0]
    end
  end
end
