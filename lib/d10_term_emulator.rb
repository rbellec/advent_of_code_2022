require "curses"

class Screen
  LEFT_PADDING = 5
  EMPTY_SPRITE_LINE = " " * 42 # 42 to ease writing sprites out of screen at left.

  def initialize
    @screen_window = Curses::Window.new(8, 42, 4, LEFT_PADDING)
    @sprite_window = Curses::Window.new(3, 42, 13, LEFT_PADDING)
    @register_window = Curses::Window.new(3, 42, 17, LEFT_PADDING)
    @code_window = Curses::Window.new(10, 42, 21, LEFT_PADDING)
    @code_window.scrollok(true)
    @screen_window.box("|", "-")
    # @register_window.box("|", "-")
    # @sprite_window.box("|", "-")

    Curses.refresh
    @code_window.refresh
    @screen_window.refresh
    # update_screen
  end

  def add_operations(op_code)
    @code_window.addstr(op_code + "\n")
  end

  def update_screen(tick, register)
    row = tick / 40
    col = tick % 40

    @screen_window.setpos(row + 1, col + 1)
    if (register - 1..register + 1).cover? col
      @screen_window.addch("#")
    else
      @screen_window.addch(".")
    end

    @screen_window.refresh
  end

  def update_tick_and_register(tick, register)
    tick_register = " %4d tick, register: %5d" % [tick, register]
    sprite_line = if register < -2
      EMPTY_SPRITE_LINE
    else
      line = EMPTY_SPRITE_LINE.dup
      line[register + 2, 3] = "---"
      line[2, 40]
    end
    @register_window.setpos(1, 1)
    @register_window.addstr(tick_register)
    @register_window.refresh

    @sprite_window.setpos(1, 1)
    @sprite_window.addstr(sprite_line)
    @sprite_window.refresh
  end
end

class Device
  attr_reader :screen, :operations, :register, :tick, :current_operation

  def initialize(operations)
    @screen = Screen.new
    @tick = 1
    @register = 1
    @next_register = 1
    @current_op = 0
    @operations = operations
  end

  def run
    operations.each do |operation|
      @current_operation = operation
      case operation
      when /noop/
        noop
      when /addx (-?\d+)/
        add($1.to_i)
      end
    end
  end

  def noop
    clock_tick
  end

  def add(offset)
    clock_tick
    clock_tick(next_register_value: @register + offset)
  end

  # tick happend at each "clock tick" and listent to events
  def clock_tick(next_register_value: nil)
    screen.add_operations(current_operation)
    screen.update_tick_and_register(tick, register)
    screen.update_screen(tick, register)

    input = Curses.getch.to_s
    exit 0 if input == "q"

    @tick += 1
    @register = next_register_value if next_register_value
  end

  DEMO_DATA = "addx 15\naddx -11\naddx 6\naddx -3\naddx 5\naddx -1\naddx -8\naddx 13\naddx 4\nnoop\naddx -1\naddx 5\naddx -1\naddx 5\naddx -1\naddx 5\naddx -1\naddx 5\naddx -1\naddx -35\naddx 1\naddx 24\naddx -19\naddx 1\naddx 16\naddx -11\nnoop\nnoop\naddx 21\naddx -15\nnoop\nnoop\naddx -3\naddx 9\naddx 1\naddx -3\naddx 8\naddx 1\naddx 5\nnoop\nnoop\nnoop\nnoop\nnoop\naddx -36\nnoop\naddx 1\naddx 7\nnoop\nnoop\nnoop\naddx 2\naddx 6\nnoop\nnoop\nnoop\nnoop\nnoop\naddx 1\nnoop\nnoop\naddx 7\naddx 1\n    noop\naddx -13\naddx 13\naddx 7\nnoop\naddx 1\naddx -33\nnoop\nnoop\nnoop\naddx 2\nnoop\nnoop\nnoop\naddx 8\nnoop\naddx -1\naddx 2\naddx 1\nnoop\naddx 17\naddx -9\naddx 1\naddx 1\naddx -3\naddx 11\nnoop\nnoop\naddx 1\nnoop\naddx 1\nnoop\nnoop\naddx -13\naddx -19\naddx 1\naddx 3\naddx 26\naddx -30\naddx 12\naddx -1\naddx 3\naddx 1\nnoop\nnoop\nnoop\naddx -9\naddx 18\naddx 1\naddx 2\nnoop\nnoop\naddx 9\nnoop\nnoop\nnoop\naddx -1\naddx 2\naddx -37\naddx 1\naddx 3\nnoop\naddx 15\naddx -21\naddx 22\naddx -6\naddx 1\nnoop\naddx 2\naddx 1\nnoop\naddx -10\nnoop\nnoop\naddx 20\naddx 1\naddx 2\naddx 2\naddx -6\naddx -11\nnoop\nnoop\nnoop\n"
end

def init_curses
  Curses.start_color # Initializes the color attributes for terminals that support it.
  Curses.curs_set(0) # Hides the cursor
  Curses.noecho # Disables characters typed by the user to be echoed by Curses.getch as they are typed.
  # Curses.init_pair(1, 2, 0)
  Curses.stdscr.scrollok true
  Curses.timeout = 100
end

def main
  init_curses
  begin
    operations = if ARGV[0]
      File.readlines(ARGV[0], chomp: true)
    else
      Device::DEMO_DATA.lines
    end
    Device.new(operations).run
  ensure
    Curses.close_screen
  end
end

main
