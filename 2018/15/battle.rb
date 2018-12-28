require_relative 'board_state'
require_relative 'unit'
require_relative 'turn'

class Battle
  def initialize(file)
    @board = BoardState.from_file(file)
    @board.print
  end

  def combat
    round = 0
    loop do
      round += 1

      full_round = live_units.each do |unit|
        next if !unit.alive?
        turn = Turn.for(unit, live_units, board)
        break if !turn.targets?
        turn.move
        turn.attack
      end

      break if !full_round

      puts "After Round #{round}"
      board.print
    end

    outcome = (round - 1) * live_units.map(&:hp).reduce(:+)
    puts "Outcome: #{outcome}"

    puts "Remaining Units"
    live_units.each do |u|
      p u
    end
  end

  private

  attr_reader :board

  def live_units
    board.
      units.
      select(&:alive?).
      sort_by { |u| u.y * 1000 + u.x }
  end
end

Battle.new(ARGV[0]).combat
