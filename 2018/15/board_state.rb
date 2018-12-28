require_relative 'constants'

class BoardState
  def self.from_file(file, elf_power)
    rows = File.read(file).split("\n").map { |line| line.strip.chars }

    units = []
    rows.each_with_index do |row, y|
      row.each_with_index do |ch, x|
        next unless ch == GOBLIN || ch == ELF
        power = ch == GOBLIN ? 3 : elf_power
        unit = Unit.new(units.length, ch, 200, power, x, y)
        rows[y][x] = unit
        units.push(unit)
      end
    end

    new(units, rows)
  end

  def initialize(units, rows)
    @rows = rows
    @units = units
  end

  attr_reader :units

  def inbounds?(x, y)
    y >= 0 && x >= 0 && y < rows.length && x < rows[0].length
  end

  def at(x, y)
    return unless inbounds?(x, y)
    rows[y][x]
  end

  def empty_at?(x, y)
    at(x, y) == EMPTY
  end

  def adjacency_pos(x, y)
    [[x, y-1], [x-1, y], [x+1, y], [x, y+1]].select { |(a,b)| inbounds?(a,b) }
  end

  def adjacencies(x, y)
    adjacency_pos(x, y).map { |(a,b)| at(a,b) }
  end

  def move_unit(unit, pos)
    rows[unit.y][unit.x] = EMPTY
    unit.x = pos[0]
    unit.y = pos[1]
    rows[unit.y][unit.x] = unit
  end

  def attack(attacker, victim)
    victim.hp -= attacker.power
    remove_dead(victim) if !victim.alive?
  end

  def print
    puts rows.map { |row| row.join }
    units.each { |u| p u }
  end

  private

  attr_reader :rows

  def remove_dead(unit)
    rows[unit.y][unit.x] = EMPTY
    unit.hp = 0
    unit.x = -1
    unit.y = -1
  end
end
