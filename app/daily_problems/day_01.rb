class Day01

  ELVES_CALORIES = [
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

  def call
    # Find the elve carrying the most calories
    elve, calories = calory_per_elve.max_by { |_elve, calories| calories }
    puts "Elve #{elve} is carrying #{calories} calories"
  end

  def calory_per_elve
    inventory_per_elve.transform_values{|inventory| inventory.sum}
  end

  def inventory_per_elve
    # Group calories by elves
    ELVES_CALORIES.chunk{|l| !l.blank?}
    .filter{|g| g.first} # supress empty lines
    .each_with_index.map{|chunk, elve_index| [elve_index, chunk.last.map(&:to_i)]}
    .to_h
  end
end
