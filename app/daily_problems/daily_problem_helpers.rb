module DailyProblemHelpers
  def open_dataset(dataset:)
    day_number = self.name.match(/\d+/)[0].to_i
    stream = case dataset
    when :test
      StringIO.new(self::TEST_DATA)
    when :problem
      File.new(DataReader.new(day: day_number).file_path)
    end
  end
end
