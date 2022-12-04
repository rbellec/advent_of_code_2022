class DataReader

  attr_reader :day, :problem, :extention

  def initialize(day: ,problem: 1, extention: "txt")
    @day = day
    @problem = problem
    @extention = extention
  end

  def content
    @content ||= read_file
  end

  def file_path
    filename = "data_day_#{day}_#{problem}.#{extention}"
    Rails.root.join('problems_data').join(filename)
  end

  def read_file
     File.readlines(file_path, chomp: true)
  end
end
