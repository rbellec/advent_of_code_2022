class Day16
  extend DailyProblemHelpers

  TEST_DATA_1 = <<~DATA
    Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
    Valve BB has flow rate=13; tunnels lead to valves CC, AA
    Valve CC has flow rate=2; tunnels lead to valves DD, BB
    Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
    Valve EE has flow rate=3; tunnels lead to valves FF, DD
    Valve FF has flow rate=0; tunnels lead to valves EE, GG
    Valve GG has flow rate=0; tunnels lead to valves FF, HH
    Valve HH has flow rate=22; tunnel leads to valve GG
    Valve II has flow rate=0; tunnels lead to valves AA, JJ
    Valve JJ has flow rate=21; tunnel leads to valve II
  DATA

  TEST_DATA = TEST_DATA_1

  def self.call(problem = false)
    dataset = problem ? :problem : :test
    day_solver = new(open_dataset(dataset: dataset))
    day_solver.problem_2
  end

  class Room
    attr_reader :name, :flow_rate, :next_room_names, :reduced_path
    attr_accessor :path_to_working_rooms
    def initialize(name:, flow_rate:, next_room_names:)
      @name = name
      @flow_rate = flow_rate
      @next_room_names = next_room_names
    end

    def valve_working?
      flow_rate > 0
    end
  end

  def initialize(data_stream)
    read(data_stream)
    reduce_graph
  end

  def read(stream)
    line_parser = Regexp.new(/Valve (\w{2}) has flow rate=(\d+); (.+) valves? (.+)/)
    @rooms_definitions = stream.each_line.map do |line|
      line.chomp!
      match_data = line_parser.match(line)
      Room.new(
        name: match_data[1],
        flow_rate: match_data[2].to_i,
        next_room_names: match_data[4].split(/\s*,\s*/)
      )
    end

    @rooms_by_name = rooms_definitions.map { |room| [room.name, room] }.to_h
    # @working_valves = rooms_definitions.filter{|room| room[:name] == "AA" || room[:flow_rate] > 0}.map{|room| room[:name]}
  end

  # @param path: Hash of key : room name, value: distance to original point or false if not calculated yet
  def shortest_paths_from(paths:, current_room_name:, current_distance:)
    # Do nothing if path to current_room is already the shortest.
    unless paths[current_room_name] && paths[current_room_name] < current_distance
      # Otherwise calculate new paths from here.
      paths[current_room_name] = current_distance
      rooms_by_name[current_room_name].next_room_names.each do |next_room_name|
        shortest_paths_from(paths: paths, current_room_name: next_room_name, current_distance: 1 + current_distance)
      end
    end
  end

  def shortest_paths_to_working_valves_for(room:)
    paths = Hash.new(false)
    shortest_paths_from(paths: paths, current_room_name: room.name, current_distance: 0)
    room.path_to_working_rooms = paths.select { |k, v| rooms_by_name[k].valve_working? }
  end

  # Calculates shortest paths from all working_valves and original room.
  # Modifies the rooms_definitions in place.
  def reduce_graph
    @rooms_definitions.filter(&:valve_working?).each do |room|
      shortest_paths_to_working_valves_for(room: room)
    end
    shortest_paths_to_working_valves_for(room: rooms_by_name["AA"])
  end

  class PathElement
    attr_reader :room_name, :minute_entered_in_room, :relase_per_minute, :release_duration, :total_released_by_this_operation
    attr_reader :path_score, :operator

    def initialize(room_name:, minutes_when_entering_room:, relase_per_minute:, release_duration:,
      total_released_by_this_operation:, path_score:, operator:)
      @room_name = room_name
      @relase_per_minute = relase_per_minute
      @minute_entered_in_room = minutes_when_entering_room

      @release_duration = release_duration
      @total_released_by_this_operation = total_released_by_this_operation
      @path_score = path_score
      @operator = operator
    end

    def self.initial_node(room_name: "AA", operator: :human, paths_start_at_minute: 1)
      # Note : we consider only rooms where valves are opened, so 1 is always added later,
      # we have to consider they entered in first room at `first_minute - 1``
      new(room_name:, minutes_when_entering_room: paths_start_at_minute - 1, relase_per_minute: 0, release_duration: 0,
        total_released_by_this_operation: 0, path_score: 0, operator:)
    end

    def pressure_release_started_at = minute_entered_in_room + 1

    # May change if "teach an elephant how to open a valve" becomes a valid operation. (Wait... What ????)
    def next_available_minute = pressure_release_started_at

    def to_s
      "%s Entered %s at minute %2d, valve released %3d per minute since minute %2d. Total released %4d, path_score: %4d" %
        [operator.to_s.ljust(10),
          room_name, minute_entered_in_room, relase_per_minute, pressure_release_started_at, total_released_by_this_operation,
          path_score]
    end
  end

  # Explore path and yield them to a block in order to use an enumerator later.
  # Idea : try making a ruby recurse scheme that can create enumerators
  def explore_path(total_minutes_available, current_path, current_path_score, &block)
    # select the next available operator
    current_operator_positions = current_path.group_by(&:operator).transform_values! { |operator_path| operator_path.max_by(&:next_available_minute) }.values
    remaining_operators = current_operator_positions.filter { _1.next_available_minute <= total_minutes_available }.sort_by(&:next_available_minute)

    # Note : in case we have multiple elephant (next idea, but not sure I'll have time to test i) we have to explore different operator orders.

    if remaining_operators.empty?
      yield current_path
      return
    end

    remaining_operators.each do |operator_path_element|
      # Examine options for this operator
      operator_room_name = operator_path_element.room_name
      current_minute = operator_path_element.next_available_minute

      possible_next_directions = rooms_by_name[operator_room_name].path_to_working_rooms.except(*current_path.map(&:room_name))
      possible_next_directions_in_remaining_time = possible_next_directions.reject { _2 + current_minute > total_minutes_available }

      if possible_next_directions_in_remaining_time.empty?
        # End of path for this operator. We return the full path even of other did not finish, can optimize later (and will never do, of course !)
        yield current_path
      else
        # Try all available directions
        possible_next_directions_in_remaining_time.each do |room_name, distance|
          minutes_when_entering_room = current_minute + distance
          minute_pressure_release_starts = minutes_when_entering_room + 1

          release_duration = 1 + total_minutes_available - minute_pressure_release_starts
          valve_release = rooms_by_name[room_name].flow_rate
          total_released_by_this_operation = release_duration * valve_release

          # We can leave next room at the same minute pressure release starts
          # next_current_minute = minute_pressure_release_starts
          next_total_released_pressure = current_path_score + total_released_by_this_operation

          path_step_record = PathElement.new(
            room_name:, minutes_when_entering_room:, relase_per_minute: valve_release, release_duration:,
            total_released_by_this_operation:, path_score: next_total_released_pressure, operator: operator_path_element.operator
          )
          # byebug if minutes_left > 27 && room_name == "DD"
          # reminder : passing a block is just here to allow using Enumerator pattern.
          explore_path(total_minutes_available, current_path + [path_step_record], next_total_released_pressure, &block)
        end
      end
    end
  end

  def problem_1
    # byebug
    path_initial_node = PathElement.initial_node(room_name: "AA", paths_start_at_minute: 1, operator: :human)
    path_explorer = enum_for(:explore_path, 30, [path_initial_node], 0)

    winning_path = path_explorer.max_by { |path| path.last.path_score }
    puts "PathScore: #{winning_path.last.path_score}"
    puts winning_path.map(&:to_s).join("\n")

    winning_path.last.path_score
    # PathScore: 2359
    # Entered AA at minute  1, valve released   0 per minute since minute  2. Total released    0, path_score:    0
    # Entered PH at minute  3, valve released  11 per minute since minute  4. Total released  297, path_score:  297
    # Entered AW at minute  6, valve released  21 per minute since minute  7. Total released  504, path_score:  801
    # Entered LX at minute  9, valve released  22 per minute since minute 10. Total released  462, path_score: 1263
    # Entered IN at minute 13, valve released  16 per minute since minute 14. Total released  272, path_score: 1535
    # Entered OW at minute 16, valve released  25 per minute since minute 17. Total released  350, path_score: 1885
    # Entered QR at minute 19, valve released  20 per minute since minute 20. Total released  220, path_score: 2105
    # Entered SV at minute 22, valve released  24 per minute since minute 23. Total released  192, path_score: 2297
    # Entered HH at minute 26, valve released  12 per minute since minute 27. Total released   48, path_score: 2345
    # Entered HX at minute 29, valve released  14 per minute since minute 30. Total released   14, path_score: 2359
  end

  def problem_2
    initial_path = [
      PathElement.initial_node(room_name: "AA", paths_start_at_minute: 1, operator: :human),
      PathElement.initial_node(room_name: "AA", paths_start_at_minute: 1, operator: :elephant)
    ]

    path_explorer = enum_for(:explore_path, 26, initial_path, 0)

    # winning_path = path_explorer.max_by { |path| path.last.path_score }
    # winning_path = path_explorer.next

    last_best_score = 1
    best_path = nil
    path_explorer.each do |path|
      score = path.last.path_score
      if score > last_best_score
        last_best_score = score
        best_path = path
        puts ""
        puts ""
        puts "PathScore: #{path.last.path_score}"
        puts path.map(&:to_s).join("\n")
      end
    end

    # @best_path = best_path
    # self
    ""
  end

  attr_reader :rooms_definitions, :rooms_by_name, :working_valves, :results
end
