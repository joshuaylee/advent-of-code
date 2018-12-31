require 'set'

LUMBERYARD = "#"
TREES = "|"
OPEN = "."

def load_initial_state(file)
  File.open(file).read.split("\n").map(&:chars)
end

def get_at(state, x, y)
  return if x < 0 || x >= state[0].length || y < 0 || y >= state.length
  state[y][x]
end

def adjacent_counts(state, x, y)
  [
    y-1, x-1,
    y-1, x,
    y-1, x+1,
    y, x-1,
    y, x+1,
    y+1, x-1,
    y+1, x,
    y+1, x+1
  ].
  each_slice(2).
  map { |(y,x)| get_at(state, x, y) }.
  group_by(&:itself).
  transform_values(&:length)
end

#
# An open acre will become filled with trees if three or more adjacent acres contained trees. Otherwise, nothing happens.
# An acre filled with trees will become a lumberyard if three or more adjacent acres were lumberyards. Otherwise, nothing happens.
# An acre containing a lumberyard will remain a lumberyard if it was adjacent to at least one other lumberyard and at least one acre containing trees. Otherwise, it becomes open.
#
def tick(state)
  y = -1
  state.map do |row|
    y += 1
    x = -1
    row.map do |ch|
      x += 1
      adj = adjacent_counts(state, x, y)
      if ch == OPEN && adj[TREES].to_i >= 3
        TREES
      elsif ch == TREES && adj[LUMBERYARD].to_i >= 3
        LUMBERYARD
      elsif ch == LUMBERYARD && !(adj[LUMBERYARD].to_i >= 1 && adj[TREES].to_i >= 1)
        OPEN
      else
        ch
      end
    end
  end
end

def viz(state)
  puts state.map(&:join)
end

def state_str(state)
  state.map(&:join).join
end

state = load_initial_state(ARGV[0])
memo = {}
goal = ARGV[1].to_i
tick = 0
while tick < goal
  if !memo.key?(state)
    memo[state] = tick
    state = tick(state)
    tick += 1
  else
    last_tick = memo[state]
    jump = tick - last_tick
    num_jumps = (goal - tick) / jump

    if num_jumps > 0
      tick += num_jumps * jump
    else
      state = tick(state)
      tick += 1
    end
  end
end

lumberyards = state.flatten.count { |ch| ch == LUMBERYARD }
trees = state.flatten.count { |ch| ch == TREES }
puts "After #{goal} minutes there are #{trees} wooded acres and #{lumberyards} lumberyards, giving a resource value of #{lumberyards * trees}"
