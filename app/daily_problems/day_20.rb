class Day20
  extend DailyProblemHelpers

  TEST_DATA = <<~DATA
    1
    2
    -3
    3
    -2
    0
    4
  DATA

  def self.call(level=1,problem = false)
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
    @initial_code = stream.each_line.map do |line|
      line.chomp.to_i
    end
  end

  # test with -1, 0, +1, > size and < -size
  def move(index, array)
    max_index = array.size - 1
    item = array.delete_at(index)
    value = item[:value]

    # value = array.delete_at(index)
    new_index = (index + value) % max_index
    if (new_index == 0)
      new_index = max_index
    end

    # initially used for problem 1. Would be removed in real world software.
    item[:moved] = true
    # puts "move #{value} at #{index} to #{new_index}"
    array.insert(new_index, item)

    # Return the new index to ease traversing the array.
    new_index
  end

  # I did not plan that I could not use my favorite unit test framework without setting up database & etc...
  # No time for this today, tested in console with
  # move(2, [0,0,1,0,0])
  # move(2, [0,0,-1,0,0])
  # move(2, [0,0,-2,0,0])
  # move(2, [0,0,2,0,0])
  # move(2, [0,0,-3,0,0])
  # move(2, [0,0,3,0,0])
  # move(2, [0,0,5,0,0])


  def problem_1
    work_array = initial_code.map{ |num| {value: num, moved: false} }
    puts work_array.map{_1[:value]}.join(", ")

    # Looking from the beginning of the array may not be optimal (n^2) but seems easy enough to try first
    while next_item_index = work_array.find_index{not _1[:moved]}
      # puts ""
      element_added_at = move(next_item_index, work_array)
      # puts work_array.map{_1[:value]}.join(", ")
    end
    result = work_array.map{_1[:value]}

    grove_coordinates(work_array)

  end

  def problem_2
    decryption_key = 811589153
    work_array = initial_code.each_with_index.map do |num, index|
      # current_index could have been used for a faster algorithm (or linked lists). Will see.
      { value: 811589153 * num,
        initial_index: index,
        current_index: index
      }
    end

    10.times do
      # work_array.each_with_index do |element, index|
      #   element[:current_index] = index
      # end

      # There is a shorter way than finding the next element every time... I'll have a look at other solutions :)
      (0...initial_code.size).each do |initial_index|
        elem_index = work_array.find_index{|element| element[:initial_index] == initial_index}
        move(elem_index, work_array)
      end
    end

    grove_coordinates(work_array)
  end

  def grove_coordinates(array)
    index_of_0 = array.find_index{_1[:value] == 0}
    answer_locations = [1000, 2000, 3000].map{(_1 + index_of_0) % array.size}
    answers = answer_locations.map{array[_1][:value]}

    puts answers.join(", ")
    answers.sum
  end

  attr_reader :initial_code
end
