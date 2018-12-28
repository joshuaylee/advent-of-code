require_relative 'constants'
require 'set'

class Turn
  def self.for(unit, units, board)
    new(unit, units.select { |u| u.type != unit.type }, board)
  end

  def initialize(unit, targets, board)
    @unit = unit
    @targets = targets.to_set
    @board = board
  end

  def move
    return unless targets?
    return if select_enemy_in_range

    nearest_enemy = search_nearest(unit.pos, targets.map(&:pos))
    return unless nearest_enemy

    move_to = search_nearest(nearest_enemy, move_choices)
    board.move_unit(unit, move_to)
  end

  def attack
    enemy = select_enemy_in_range
    board.attack(unit, enemy) if enemy
  end

  def targets?
    targets.any?
  end

  private

  attr_reader :unit, :targets, :board

  def move_choices
    board.adjacency_pos(unit.x, unit.y).
      select { |(x, y)| board.empty_at?(x, y) }
  end

  def search_nearest(origin_coords, search_targets)
    edges = [origin_coords]
    visited = Set.new(edges.dup)
    loop do
      edges = expand_search(edges, visited, search_targets)
      return if edges.empty?

      nearest_search_targets = edges & search_targets
      return choose_first(nearest_search_targets) if nearest_search_targets.any?
    end
  end

  def expand_search(edges, visited, search_targets)
    new_edges = Set.new
    edges.each do |edge|
      board.adjacency_pos(*edge).each do |pos|
        next if visited.include?(pos)
        if board.empty_at?(*pos) || search_targets.include?(pos)
          new_edges.add(pos)
          visited.add(pos)
        end
      end
    end
    new_edges
  end

  def choose_first(pos_set)
    first = pos_set.
      map { |(x, y)| y * 1000 + x }.
      sort.
      first

    [first % 1000, first / 1000]
  end

  def select_enemy_in_range
    board.adjacencies(unit.x, unit.y).
      select { |x| x.is_a?(Unit) && x.type != unit.type }.
      min_by(&:hp)
  end
end
