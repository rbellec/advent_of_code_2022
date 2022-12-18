class Day15
  extend DailyProblemHelpers

  TEST_DATA_1 = <<~DATA
    Sensor at x=2, y=18: closest beacon is at x=-2, y=15
    Sensor at x=9, y=16: closest beacon is at x=10, y=16
    Sensor at x=13, y=2: closest beacon is at x=15, y=3
    Sensor at x=12, y=14: closest beacon is at x=10, y=16
    Sensor at x=10, y=20: closest beacon is at x=10, y=16
    Sensor at x=14, y=17: closest beacon is at x=10, y=16
    Sensor at x=8, y=7: closest beacon is at x=2, y=10
    Sensor at x=2, y=0: closest beacon is at x=2, y=10
    Sensor at x=0, y=11: closest beacon is at x=2, y=10
    Sensor at x=20, y=14: closest beacon is at x=25, y=17
    Sensor at x=17, y=20: closest beacon is at x=21, y=22
    Sensor at x=16, y=7: closest beacon is at x=15, y=3
    Sensor at x=14, y=3: closest beacon is at x=15, y=3
    Sensor at x=20, y=1: closest beacon is at x=15, y=3
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
    line_parser = Regexp.new(/Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/)
    @sensors = stream.each_line.map do |line|
      line.chomp!
      match_data = line_parser.match line
      sensor = Coord.new(match_data[1].to_i, match_data[2].to_i)
      beacon = Coord.new(match_data[3].to_i, match_data[4].to_i)
      [sensor, beacon]
    end
    # @place_map = Map2d.create_from_coord_list(sensors.keys + sensors.values, build_map: false)
    # @x_min = place_map.x_min
    # @y_min = place_map.y_min
    # @x_max = place_map.x_max
    # @y_max = place_map.y_max
    # sensors.keys.each { place_map.set(_1, :sensor) }
    # sensors.values.each { place_map.set(_1, :beacon) }
    @distances = sensors.map { |sensor, beacon| {sensor: sensor, beacon: beacon, distance: sensor.manhattan_distance(beacon)} }
    # @complete_line_range = MultiRange.new([x_min..x_max])
  end

  def print_map
    str_map = place_map.print_map_status do |element|
      case element
      when false
        "."
      when :sensor
        "S"
      when :beacon
        "B"
      end
    end

    puts str_map
  end

  def coverage_range_for_line(line_number)
    # To print coverage information
    # not_cover = []
    # covers = []

    raw_coverage_ranges = distances.map do |definition|
      sensor = definition[:sensor]
      # beacon = definition[:beacon]
      distance = definition[:distance]

      y_diff = (line_number - sensor.y).abs

      coverage_distance = distance - y_diff
      if coverage_distance < 0
        # not_cover << "sensor #{sensor.to_s(3)}, coverage #{distance} (#{coverage_distance} on line #{line_number}), no coverage on line."
        nil
      else
        result = (sensor.x - coverage_distance..sensor.x + coverage_distance)
        # covers << "cover from %3d to %3d " % [result.begin, result.end] + "sensor #{sensor.to_s(3)}, distance #{distance} covers #{coverage_distance.to_s.ljust(3)} on line #{line_number}"
        result
      end
    end.compact

    # puts (covers + not_cover).join("\n")

    # Coverage is possible outside of the map range.
    MultiRange.new(raw_coverage_ranges).merge_overlaps
  end

  def problem_1
    distances.map { |a| "#{a[:sensor].to_s(3)} | #{a[:beacon].to_s(3)} | #{a[:distance]}" }

    # coverage = coverage_range_for_line(10)
    coverage = coverage_range_for_line(2000000)

    coverage.ranges.sum { |r| r.end - r.begin }

    # Found multi range gem whith already does the boiler-plate for ranges

    # print_map
    # self
  end

  def problem_2
    problem_range = MultiRange.new([0..4_000_000])
    # problem_range = MultiRange.new([0..20])
    results = []
    problem_range.each do |line|
      line_range = problem_range - (problem_range & coverage_range_for_line(line))
      if line_range.size > 0
        results += line_range.map { Coord.new(_1, line) }
      end
      if line % 10_000 == 0
        puts line.to_s
        puts results.map(&:to_s).join(", ")
      end
    end

    results
    # solution_map.each_withfilter!{|r| r.size > 0}

    # tuning_frequency = result.x * 4000000 + result.y
  end

  attr_reader :sensors, :place_map, :x_min, :y_min, :x_max, :y_max, :distance_by_sensor, :complete_line_range, :distances
end
