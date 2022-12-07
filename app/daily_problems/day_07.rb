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
    include Enumerable
    attr_reader :parent, :name, :type, :size, :content
    attr_writer :parent
    def initialize(parent:, name:, type:, size: 0, content: nil)
      @parent = parent
      @name = name
      @type = type
      @size = size
      @content = content
    end

    def subdir_size = 0

    def full_path
      name == "/" ? Pathname("/") : parent.full_path.join(name)
    end

    def each(&block)
      yield self
      if type == :directory
        content.each { |elem| elem.each(&block) }
      end
    end

    def print_tree(path = "/", level = 0)
      current_path = Pathname(path).join(name)
      string_path = "  " * level + current_path.to_s
      if type == :directory
        [string_path, *content.map { |f| f.print_tree(current_path, level + 1) }].flatten
      else
        string_path
      end
    end
  end

  class DFile < DFileItem
    def initialize(parent:, name:, size:)
      super(parent:, name:, size:, type: :file)
    end

    def total_size
      size
    end
  end

  class DDirectory < DFileItem
    def initialize(parent:, name:)
      super(parent: parent, name: name, size: 0, type: :directory, content: [])
    end

    def add_file(filename, size)
      new_file = DFile.new(parent: self, name: filename, size: size)
      content << new_file
      new_file
    end

    def add_dir(subdir_name)
      return if subdir_name == "/"
      new_dir = DDirectory.new(parent: self, name: subdir_name)
      content << new_dir
      new_dir
    end

    def total_size
      @total_size ||= content.sum(&:total_size)
    end

    def self.new_root
      root = new(parent: nil, name: "/")
      root.parent = root
      root
    end
  end

  attr_reader :root, :data_stream, :current_dir

  def initialize
    @root = DDirectory.new_root
    @current_dir = @root

    @data_stream = StringIO.new(TEST_DATA)
    # data_stream = @stream = File.new(DataReader.new(day: 7).file_path)
    read_data
  end

  def self.call
    # new.root.print_tree

    Day07.new.problem_1
  end

  def problem_1
    directories = root.filter { |f| f.type == :directory }
    directories.map { |d| [d.name, d.total_size] }
  end

  def problem_2
  end

  def get_create_dir(name)
    directory = current_dir.content.find { |d| d.name == name } # && d.type == :directory ?
    directory.nil? ? current_dir.add_dir(name) : directory
  end

  def show
    root.map(&:name).join(", ")
  end

  def read_data
    data_stream.readlines.each do |line|
      line.chomp!

      case line
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
        current_dir.add_file($2, $1.to_i)
      else
        puts "Urecognized line:" + line
      end
    end
    self
  end
end
