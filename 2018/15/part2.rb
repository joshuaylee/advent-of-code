require_relative 'battle'

safe_power = nil
elf_power = 3

until_elf_dies = Proc.new do |full_round, board|
  any_elf_deaths = board.units.any? { |unit| unit.elf? && !unit.alive? }
  if !full_round
    safe_power = elf_power if !any_elf_deaths
    true
  else
    any_elf_deaths
  end
end

loop do
  elf_power += 1
  battle = Battle.new(ARGV[0], elf_power)
  battle.combat(until_proc: until_elf_dies)

  if safe_power
    battle.print_outcome
    break
  end
end

puts "The Elves need #{safe_power} attack power to avoid any deaths"
