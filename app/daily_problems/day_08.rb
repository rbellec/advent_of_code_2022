class Day08
  TEST_DATA = <<~DATA
    30373
    25512
    65332
    33549
    35390
  DATA

  def initialize
    # @tree_rows = read(StringIO.new(TEST_DATA))
    @tree_rows = read(File.new(DataReader.new(day: 8).file_path))
    @tree_columns = transpose(@tree_rows)
  end

  def transpose(matrix)
    colums_count = matrix.first.size
    # transposed trees matrix
    (0...colums_count).map { |col_index| matrix.map { |row| row[col_index] } }
  end

  def self.call
    new.problem_2
  end

  # For a sequence of int, return the sequence replacing invisible trees by nil.
  def visible_trees(tree_sequence, direction = :straight)
    if direction == :reverse
      visible_trees(tree_sequence.reverse).reverse
    else
      tree_sequence.inject([]) do |visible_trees, current_tree|
        visible_trees.append(visible_trees.empty? || current_tree > visible_trees.compact.last ? current_tree : nil)
      end
    end
  end

  # For a sequence of int, return the sequence replacing invisible trees by nil.
  def scenic_scores(sequence)
    size = sequence.size
    sequence.each_with_index.map do |tree, index|
      before = sequence.slice(0, index).reverse
      after = sequence.slice(index + 1, size - index)
      before_trees = visible_trees_from(tree, before)
      after_trees = visible_trees_from(tree, after)
      before_trees * after_trees
    end
  end

  def visible_trees_from(tree, line_of_sight)
    if line_of_sight.empty?
      0
    else
      blocking_tree_index = line_of_sight.find_index { |i| i >= tree }
      if blocking_tree_index.nil?
        line_of_sight.size
      else
        blocking_tree_index + 1
      end
    end
  end

  def merge_matrix(matrix1, matrix2)
    matrix1.zip(matrix2).map do |row_a, row_b|
      row_a.zip(row_b).map do |elem_a, elem_b|
        yield(elem_a, elem_b)
      end
    end
  end

  def merge_visibility(matrix1, matrix2)
    merge_matrix(matrix1, matrix2) { |a, b| a || b }
  end

  # run the block for all line and colums in both direction
  # Finally not used !
  def run_from_all_edges(&block)
    result = tree_rows.flat_map { |row| [yield(row), yield(row.reverse)] }
    result += tree_columns.flat_map { |column| [yield(column), yield(column.reverse)] }
    result
  end

  def problem_2
    row_scores = tree_rows.map(&method(:scenic_scores))
    col_scores = tree_columns.map(&method(:scenic_scores))
    result = merge_matrix(row_scores, transpose(col_scores)) { |a, b| a * b }
    print_trees(result)
    result.flatten.max
  end

  def problem_1
    result = all_visible_trees
    print_trees(result)
    result.flatten.compact.count
  end

  def all_visible_trees
    return @all_visible_trees if @all_visible_trees
    visible_from_w = tree_rows.map { visible_trees(_1) }
    visible_from_e = tree_rows.map { visible_trees(_1, :reverse) }
    visible_from_n = tree_columns.map { visible_trees(_1) }
    visible_from_s = tree_columns.map { visible_trees(_1, :reverse) }

    lines = merge_visibility(visible_from_e, visible_from_w)
    cols = merge_visibility(visible_from_n, visible_from_s)
    @all_visible_trees = merge_visibility(lines, transpose(cols))
  end

  def print_trees(matrix)
    colsep = ""
    string = matrix.map { |row| row.map { |tree| (tree || ".").to_s }.join(colsep) }.join("\n")
    puts string
  end

  def read(stream)
    stream.readlines.map do |line|
      line.chomp!.chars.map(&:to_i)
    end
  end

  attr_reader :tree_rows, :tree_columns
end
