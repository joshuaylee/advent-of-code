require_relative 'battle'

battle = Battle.new(ARGV[0])
battle.combat(until_proc: -> (full_round, _board) { !full_round })
battle.print_outcome
