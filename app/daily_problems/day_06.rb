class Day06
  TEST_DATA = "mjqjpqmgbljsphdztnvjfqwrcgsmlb"

  def self.call
    new.problem_2
  end

  attr_reader :stream

  def initialize
    # @stream = StringIO.new(TEST_DATA)
    @stream = File.new(DataReader.new(day: 6).file_path)
  end

  def problem_1
    detect(marker_size: 4)
  end

  def problem_2
    detect(marker_size: 14)
  end

  def detect(marker_size:)
    buffer = stream.read(marker_size).chars
    begin
      loop do
        return stream.tell, buffer if buffer.uniq.count == marker_size
        return nil if stream.eof?
        buffer.shift
        buffer.push(stream.getc)
      end
    ensure
      stream.close
    end
  end
end
