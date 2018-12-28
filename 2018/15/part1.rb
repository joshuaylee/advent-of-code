require_relative 'battle'

Battle.new(ARGV[0]).combat(until_proc: -> (full_round, _board) { !full_round })
