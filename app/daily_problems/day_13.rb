class Day13
  extend DailyProblemHelpers

  TEST_DATA_1 = <<~DATA
    [1,1,3,1,1]
    [1,1,5,1,1]

    [[1],[2,3,4]]
    [[1],4]

    [9]
    [[8,7,6]]

    [[4,4],4,4]
    [[4,4],4,4,4]

    [7,7,7,7]
    [7,7,7]

    []
    [3]

    [[[]]]
    [[]]

    [1,[2,[3,[4,[5,6,7]]]],8,9]
    [1,[2,[3,[4,[5,6,0]]]],8,9]
  DATA

  TEST_DATA_2 = <<~DATA
    .
  DATA

  TEST_DATA = TEST_DATA_1

  def self.call(problem = false)
    dataset = problem ? :problem : :test
    day_solver = new(open_dataset(dataset: dataset))
    day_solver.problem_2
  end

  def initialize(data_stream)
    read(data_stream)
  end

  def read(stream)
    @packets = stream.each_line.map do |line|
      # What do we say to the god of beautiful parsers? Not today !
      # rubocop:disable Security/Eval
      eval(line)
      # rubocop:enable Security/Eval
    end.compact

    # We always have 2 lines with lists and 1 empty line.
    @packet_pairs = packets.each_slice(2).to_a
  end

  def compare(left, right)
    Day13.compare(left, right)
  end

  def self.compare(left, right)
    # byebug
    case [left, right]
    in Integer, Integer
      left <=> right
    in Array, Array
      if left.empty? || right.empty?
        left.size <=> right.size
      else
        l_head, *l_tail = left
        r_head, *r_tail = right
        head_compare = compare(l_head, r_head)
        head_compare == 0 ? compare(l_tail, r_tail) : head_compare
      end
    else
      compare(Array.wrap(left), Array.wrap(right))
    end
  end

  # def compare(packets)

  # end

  def problem_1
    comparisons = packet_pairs.map do |pair|
      compare(*pair)
    end

    # Manual unit tests :)
    # result_str = comparisons.each_with_index.map do |res, i|
    #   [i+1, res == -1 ? "Right order" : "wrong order"].join(": ")
    # end.join("\n")
    # puts result_str

    comparisons.each_with_index.map do |result, index|
      result == -1 ? index + 1 : 0
    end.sum
  end

  def problem_2
    divider_1 = [[2]]
    divider_2 = [[6]]
    packets << divider_1
    packets << divider_2
    ordered_packets = packets.sort { |a, b| compare(a, b) }
    divider_indexes = ordered_packets.each_with_index.map do |packet, index|
      if packet == divider_1 || packet == divider_2
        index + 1
      end
    end.compact
    divider_indexes.first * divider_indexes.last
  end

  attr_reader :packet_pairs, :packets
end
