require "curses"

# Waiting time before 2 frames. Negative values means you have
# to hit a key to trigger next frame. (used as curses getch timeout)
FRAME_DURATION = 40

class Screen
  LEFT_PADDING = 5
  EMPTY_SPRITE_LINE = " " * 42 # 42 to ease writing sprites out of screen at left.

  def initialize
    @screen_window = Curses::Window.new(8, 43, 4, LEFT_PADDING)
    @sprite_window = Curses::Window.new(3, 43, 13, LEFT_PADDING)
    @register_window = Curses::Window.new(3, 43, 17, LEFT_PADDING)
    @code_window = Curses::Window.new(10, 42, 21, LEFT_PADDING + 2)
    @help_window = Curses::Window.new(6, 42, 32, LEFT_PADDING)

    @code_window.scrollok(true)
    @screen_window.box("|", "-")
    @register_window.box("|", "-")

    Curses.refresh
    present_help
  end

  def present_help
    @help_window.clear
    @help_window.box("|", "-")
    @help_window.setpos(1, 2)
    @help_window.addstr "q: quit"
    @help_window.setpos(2, 2)
    @help_window.addstr "s: stop animation"
    @help_window.setpos(3, 2)
    @help_window.addstr "r: relaunch animation"
    @help_window.setpos(4, 2)
    @help_window.addstr "any key: next clock tick"
    @help_window.refresh
  end

  def add_operations_line(tick, operation, next_register_value)
    operation_str = if next_register_value
      "\n%3d: %-12s | next register: %4d" % [tick, operation, next_register_value]
    else
      "\n%3d: %-12s |" % [tick, operation]
    end

    @code_window.addstr(operation_str)
    @code_window.clrtoeol
    @code_window.refresh
  end

  def update_screen(tick, register)
    # clock tick starts on 1, hence the adjustment.
    row = (tick - 1) / 40
    col = (tick - 1) % 40

    # +1 & +2 are for presentation only (padding in screen)
    @screen_window.setpos(row + 1, col + 2)
    if (register - 1..register + 1).cover? col
      @screen_window.attron(Curses::A_REVERSE) do
        @screen_window.addch("#")
      end
    else
      @screen_window.addch(".")
    end

    @screen_window.refresh
  end

  def update_tick_and_register(tick, register)
    tick_register = " %4d tick,    register: %5d" % [tick, register]
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

  def print_end_message
    @register_window.clear
    @register_window.box("|", "-")
    @register_window.setpos(1, 1)
    @register_window.addstr("End. Press any keys to quit.")
    @register_window.refresh
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

    screen.print_end_message
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
    screen.add_operations_line(tick, current_operation, next_register_value)
    screen.update_tick_and_register(tick, register)
    screen.update_screen(tick, register)

    input = Curses.getch.to_s
    case input
    when "q"
      exit 0
    when "s"
      Curses.timeout = -1
    when "r"
      Curses.timeout = FRAME_DURATION
    end

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
  Curses.timeout = FRAME_DURATION
end

def main
  init_curses
  begin
    operations = if ARGV[0]
      File.readlines(ARGV[0], chomp: true)
    else
      Device::DEMO_DATA.lines.map(&:chomp)
    end
    Device.new(operations).run

    Curses.timeout = -1
    Curses.getch
  ensure
    Curses.close_screen
  end
end

main
