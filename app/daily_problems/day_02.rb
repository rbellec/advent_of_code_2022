class Day02

  SCORES = {rock: 1, paper: 2, scissors: 3, lost: 0, draw: 3, win: 6}

  MOVE_CODES = {A: :rock, B: :paper, C: :scissors, X: :rock, Y: :paper, Z: :scissors}

  MOVE_CODES_2 = {A: :rock, B: :paper, C: :scissors, X: :lost, Y: :draw, Z: :win}

  class Move
    WIN_OVER = {scissors: :paper, paper: :rock, rock: :scissors}
    WON_BY  = WIN_OVER.map{|k, v| [v, k]}.to_h

    attr_reader :move

    def initialize(move)
      @move = move
    end

    # Called from opponent mode
    def solve_to(issue)
      my_move =
        case (issue)
          when :draw
            move
          when :win
            WON_BY[move]
          when :lost
            WIN_OVER[move]
          end

      Move.new(my_move)
    end

    def solve(other)
      if draw?(other)
        :draw
      elsif win_over?(other)
        :win
      else
        :lost
      end
    end

    def draw?(other)
      move == other.move
    end

    def win_over?(other)
      other.move == WIN_OVER[move]
    end
  end

  def self.call
    new.problem_2
  end

  def problem_2
    reader = DataReader.new(day: 2, problem: 1)
    lines = reader.content
    rounds = lines.map do |line|
      line.split(' ')
    end.map do |move, issue|
      opponent_move = Move.new(MOVE_CODES_2[move.to_sym])
      issue = MOVE_CODES_2[issue.to_sym]
      my_move = opponent_move.solve_to(issue)
      score(me: my_move, opponent: opponent_move)
    end.sum
  end

  def problem_1
    reader = DataReader.new(day: 2, problem: 1)
    lines = reader.content
    rounds = lines.map do |line|
      line.split(' ').map{|move| Move.new(MOVE_CODES[move.to_sym])}
    end
    scores = rounds.map do |opponent, me|
      score(me: me, opponent: opponent)
    end
    score = scores.sum
  end

  def score(me:, opponent:)
    move_value = SCORES[me.move]
    issue_score = SCORES[me.solve(opponent)]
    round_score = move_value + issue_score
  end
end
