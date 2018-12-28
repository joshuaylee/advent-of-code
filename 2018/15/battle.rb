require_relative 'board_state'
require_relative 'unit'
require_relative 'turn'

class Battle
  attr_reader :elf_power, :outcome

  def initialize(file, elf_power=3)
    @board = BoardState.from_file(file, elf_power)
    @elf_power = elf_power
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
    end

    hp_remaining = live_units.map(&:hp).reduce(:+)
    outcome = (round - 1) * hp_remaining
    puts "Outcome: #{round - 1 } x #{hp_remaining } = #{outcome}"
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
