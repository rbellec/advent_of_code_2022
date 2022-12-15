class Map2d
  attr_reader :height, :width, :x_max, :x_min, :y_max, :y_min

  def self.create_from_coord_list(coord_list)
    xs = coord_list.map(&:x)
    ys = coord_list.map(&:y)

    # new(x_min: xs.min, x_max: xs.max, y_min: ys.min, y_max: ys.max, default_value: false)
    new(x_min: xs.min, x_max: xs.max, y_min: ys.min, y_max: ys.max)
  end

  # Later if needed
  def initialize(x_min:, x_max:, y_min:, y_max:, default_value: false)
    @x_max = x_max
    @x_min = x_min
    @y_max = y_max
    @y_min = y_min

    @height = y_max - y_min + 1
    @width = x_max - x_min + 1

    @map_content = Array.new(height) { Array.new(width, default_value) }
  end

  def get(coord)
    map_content[coord.y - y_min][coord.x - x_min]
  end

  def set(coord, value)
    map_content[coord.y - y_min][coord.x - x_min] = value
  end

  def row(y)
    map_content[y - y_min]
  end

  def column(x)
    map_content.map{|row| row[x - x_min]}
  end

  # Take a block to print each element
  def print_map_status(sep="")
    map_content.map do |row|
      row.map do |value|
        block_given? ? yield(value) : value
      end.join(sep)
    end.join("\n")
  end

  private
  attr_reader :map_content
  attr_writer :map_content, :height, :width, :x_max, :x_min, :y_max, :y_min

end
