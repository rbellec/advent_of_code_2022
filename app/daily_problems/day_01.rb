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
    "1000"
  ]

  # Note : since puzzle input differ by user, I have to save it on disk from browser and can't just
  # read it online.
  # PROBLEM_1_DATA_URL = "https://adventofcode.com/2022/day/1/input"

  def self.test_with_sample
    new.call(ELVES_CALORIES_SAMPLE)
  end

  def self.problem_1
    # Solution: Elve 79 is carrying 69836 calories
    reader = DataReader.new(day: 1, problem: 1)
    new.problem_1(reader.content)
  end

  def self.problem_2(test_data: true)
    data = test_data ? ELVES_CALORIES_SAMPLE : DataReader.new(day: 1, problem: 1).content
    new.problem_2(data)
  end

  def problem_1(data)
    # Find the elve carrying the most calories
    elve, calories = calory_per_elve(data).max_by { |_elve, calories| calories }
    puts "Elve #{elve} is carrying #{calories} calories"
  end

  def problem_2(data)
    # Top 3 elves carry 207968 calories.
    top_3_elves = sorted_elves_calories_assoc(data).first(3)
    top_3_elves.map(&:last).sum
  end

  # [[elve, calories], ...] sorted by calories amount
  def sorted_elves_calories_assoc(data)
    calory_per_elve(data).sort_by { |_elve, calories| calories }.reverse
  end

  def calory_per_elve(data)
    inventory_per_elve(data).transform_values { |inventory| inventory.sum }
  end

  def inventory_per_elve(data)
    # Group calories by elves
    data.chunk { |l| !l.blank? }
      .filter { |g| g.first } # supress empty lines
      .each_with_index.map { |chunk, elve_index| [elve_index, chunk.last.map(&:to_i)] }
      .to_h
  end

  attr_reader :data
end
