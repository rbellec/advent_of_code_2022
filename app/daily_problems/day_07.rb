class Day07
  TEST_DATA = <<~DATA
    $ cd /
    $ ls
    dir a
    14848514 b.txt
    8504156 c.dat
    dir d
    $ cd a
    $ ls
    dir e
    29116 f
    2557 g
    62596 h.lst
    $ cd e
    $ ls
    584 i
    $ cd ..
    $ cd ..
    $ cd d
    $ ls
    4060174 j
    8033020 d.log
    5626152 d.ext
    7214296 k
  DATA

  class DFileItem
    attr_reader :parent, :name, :type, :size, :content

    def initialize(parent:, name:, type:, size: 0, content: nil)
      @parent = parent
      @name = name
      @type = type
      @size = size
      @content = content
    end

    def subdir_size = 0
  end

  class DFile < DFileItem
    def initialize(parent:, name:, size:)
      super(parent:, name:, size:, type: :file)
    end

    def total_size
      size
    end

    def print_tree(path, level)
      path + "/" + name
    end
  end

  class DDirectory < DFileItem
    attr_writer :parent

    def initialize(parent:, name:)
      super(parent:, name:, size: 0, type: :directory, content: [])
    end

    def add_file(file) = content << file

    def content_size
      # Dir have a 0 size to avoid filter here
      content.sum(&:size)
    end

    def subdir_size
      content.sum(&:subdir_size)
    end

    def total_size
      content_size + subdir_size
    end

    def self.new_root
      root = new(parent: nil, name: "/")
      root.parent = root
      root
    end

    def print_tree(path, level = 0)
      if level == 0
        ["/"] + content.map { |f| f.print_tree("", level + 1) }
      else
        current_path = path + "/" + name
        [current_path] + content.map { |f| f.print_tree(current_path, level + 1) }
      end
    end
  end

  attr_reader :root, :data_stream, :current_dir

  def initialize
    @root = DDirectory.new_root
    @current_dir = @root

    @data_stream = StringIO.new(TEST_DATA)
    # data_stream = @stream = File.new(DataReader.new(day: 7).file_path)
  end

  def self.call
    solver = new
    solver.read_data
    solver.root.print_tree("", 0)
  end

  def problem_1
  end

  def problem_2
  end

  def get_create_dir(name)
    directory = current_dir.content.find { |d| d.name == name } # && d.type == :directory ?
    if directory.nil?
      directory = DDirectory.new(parent: current_dir, name: name)
      current_dir.add_file(directory)
    end
    directory
  end

  def read_data
    data_stream.readlines.each do |line|
      case line.chomp
      when "$ cd /"
        @current_dir = root
      when "$ cd .."
        @current_dir = current_dir.parent
      when /\$ cd ([\w\-.]+)/
        new_dir = get_create_dir($1)
        @current_dir = new_dir
      when "$ ls"
        # Nothing to do
      when /dir ([\w\-.]+)/
        get_create_dir($1)
      when /(\d+)\s+([\w\-.]+)/
        current_dir.add_file(DFile.new(parent: current_dir, name: $2, size: $1.to_i))
      else
        puts "Urecognized line:" + line
      end
    end
  end
end
