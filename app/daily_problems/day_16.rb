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

  TEST_DATA_2 = <<~DATA
    .
  DATA

  TEST_DATA = TEST_DATA_1

  def self.call(problem = false)
    dataset = problem ? :problem : :test
    day_solver = new(open_dataset(dataset: dataset))
    day_solver.problem_1
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

    @rooms_by_name = rooms_definitions.map{|room| [room.name, room]}.to_h
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

  def shortest_paths_to_working_valves_for(room: )
    paths = Hash.new(false)
    shortest_paths_from(paths: paths, current_room_name: room.name, current_distance: 0)
    room.path_to_working_rooms = paths.select{|k, v| rooms_by_name[k].valve_working?}
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
    attr_reader :room_name, :valve_opened, :score, :cumulated_score

    def initialize(room_name:, valve_opened:, score:, cumulated_score: , minute_entered_in_the_room:)
      room_name = room_name
      valve_opened = valve_opened
      score = score

      # Minute left the room is the same if valve is not opened.
      minute_entered_in_the_room = minute_entered_in_the_room

      # Only if this room valve is opened
      release_by_minute = release_by_minute
    end
  end

  # I tried initially a small and simple first version which worked counting from 30 minutes to 0 and using reduced graph,
  # It worked on demo data but not on problem data.
  # Explore path and yield them to a block in order to use an enumerator later.
  def explore_path(current_path, minutes, release_per_minute, total_released=0, &block)
    # Minutes < 0 could be tested now, but for clarity I'll keep all yield at the same place.
    current_room_name = rooms_by_name[current_path.last[:room_name]]
    last_release_by_minutes = current_path.last[:release_by_minute] || 0

    possible_next_directions = current_room_name
      .path_to_working_rooms
      .reject do |room_name, distance|
        current_path.map{_1[:room_name]}.include?(room_name)
      end

    if minutes > max_minutes || possible_next_directions.empty?
      yield [total_released, current_path]
    else
      possible_next_directions.each do |room_name, distance|
        next_move_minute =  minutes + distance
        next_release_minute = next_move_minute + 1
        remaining_minutes_for_next_release = max_minutes - next_move_minute
        additional_release_per_minute = rooms_by_name[room_name].flow_rate
        next_release_per_minute = release_per_minute + additional_release_per_minute
        next_total_released = total_released + (release_per_minute * distance) + next_release_per_minute

        # curent_choice_released_pressure = remaining_minutes_for_next_release * release_per_minute
        # next_released_pressure = released_pressure + curent_choice_released_pressure

        this_move = {room_name: room_name, entered_in_room: next_move_minute, valve_released: next_release_minute,
          release_by_minute: next_release_per_minute, minutes_of_release_till_end: remaining_minutes_for_next_release,
          # pressure_released_till_end: curent_choice_released_pressure,
          pressure_released_by_minute: next_release_per_minute,
          total_released: next_total_released
        }
        # byebug if minutes_left > 27 && room_name == "DD"
        explore_path(current_path + [this_move], next_release_minute, next_release_per_minute, next_total_released, &block)
      end
    end
  end

  def problem_1
    reduce_graph
    @results = []
    @max_minutes = 30
    start = {room_name: "AA", entered_in_room: 1, valve_released: false}
    # explore_path([start], 1, 0){|path| @results<<path}
    enum_for(:explore_path, [start], 1, 0).max_by(&:first)
    # self.results.max_by(&:first)
    # example: 1 is in AA but not noted
    # { 1:"AA", 2:"DD", "AA]

  end

  def problem_2
  end

  attr_reader :rooms_definitions, :rooms_by_name, :working_valves, :results, :max_minutes
end
