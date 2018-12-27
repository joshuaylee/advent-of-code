
def xrecipe
  @recipe ||= {
    "...##" => "#",
    "..#.." => "#",
    ".#..." => "#",
    ".#.#." => "#",
    ".#.##" => "#",
    ".##.." => "#",
    ".####" => "#",
    "#.#.#" => "#",
    "#.###" => "#",
    "##.#." => "#",
    "##.##" => "#",
    "###.." => "#",
    "###.#" => "#",
    "####." => "#"
  }
end

def recipe
  @recipe ||= {
    "#..#." => "#",
    "#.#.#" => "#",
    "#.#.." => "#",
    ".#..." => "#",
    ".#.##" => "#",
    "..#.." => "#",
    "..###" => "#",
    "##.#." => "#",
    "##.##" => "#",
    ".##.#" => "#",
    "...##" => "#",
    "##..." => "#",
    ".#..#" => "#",
    "####." => "#",
    ".##.." => "#"
  }
end

def initial_state
  state = {}
  # "#..#.#..##......###...###"
  "##.#.####..#####..#.....##....#.#######..#.#...........#......##...##.#...####..##.#..##.....#..####".
    chars.
    each_with_index { |c, i| state[i] = "#" if c == "#" }

  state
end

def next_gen(state)
  start = state.keys.min - 2
  stop = state.keys.max + 2
  {}.tap do |h|
    (start..stop).each do |pos|
      key = ((pos-2)..(pos+2)).map { |x| state[x] || "." }.join
      h[pos] = "#" if recipe.key?(key)
    end
  end
end

def value(state)
  state.keys.reduce(:+)
end

cur = initial_state
val = value(cur)
150.times do |i|
  cur = next_gen(cur)
  prev_val = val
  val = value(cur)
  puts "Generation #{i}: #{val}, change = #{val - prev_val}"
end

puts val


# Generation 127: 12196, change = 247
# Generation 128: 12274, change = 78
# Generation 129: 12352, change = 78
# Generation 130: 12430, change = 78

puts (50000000000 - 128) * 78 + 12196
