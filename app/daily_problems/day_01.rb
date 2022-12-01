class Day01

  ELVES_CALORIES_SAMPLE = [
    "1000",
    "2000",
    "3000",
    "",
    "4000",
    "",
    "5000",
    "6000",
    "",
    "7000",
    "8000",
    "9000",
    "",
    "1000",
  ]

  # Note : since puzzle input differ by user, I have to save it on disk from browser and can't just
  # read it online.
  # PROBLEM_1_DATA_URL = "https://adventofcode.com/2022/day/1/input"
  PROBLEM_1_DATA_URL = "https://adventofcode.com/2022/day/1/input"

  def self.test_with_sample
    new.call(ELVES_CALORIES_SAMPLE)
  end

  def self.problem_1
    # Solution: Elve 79 is carrying 69836 calories
    reader = DataReader.new(day: 1, problem: 1)
    new.call(reader.content)
  end

  def call(data)
    # Find the elve carrying the most calories
    elve, calories = calory_per_elve(data).max_by { |_elve, calories| calories }
    puts "Elve #{elve} is carrying #{calories} calories"
  end

  def calory_per_elve(data)
    inventory_per_elve(data).transform_values{|inventory| inventory.sum}
  end

  def inventory_per_elve(data)
    # Group calories by elves
    data.chunk{|l| !l.blank?}
    .filter{|g| g.first} # supress empty lines
    .each_with_index.map{|chunk, elve_index| [elve_index, chunk.last.map(&:to_i)]}
    .to_h
  end

  attr_reader :data
end
