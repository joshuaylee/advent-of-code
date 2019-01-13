require 'pry'
require 'shortest_path'

DEPTH = ARGV[0].to_i
TARGET_X = ARGV[1].to_i
TARGET_Y = ARGV[2].to_i
EROSION_CONST = 20183
PADDING = (ARGV[3] || 0).to_i

# region types
ROCKY = 0
WET = 1
NARROW = 2

# tools
NEITHER = 0
CLIMBING_GEAR = 1
TORCH = 2
PERMITTED_TOOLS = {
  ROCKY  => [CLIMBING_GEAR, TORCH],
  WET    => [CLIMBING_GEAR, NEITHER],
  NARROW => [TORCH, NEITHER],
}

# time constants
MOVE_TIME = 1
SWITCH_TIME = 7

def erosion_map
  map = []

  width = TARGET_X + PADDING
  length = TARGET_Y + PADDING

  (0..length).each do |y|
    row = Array.new(width)
    map.push(row)

    (0..width).each do |x|
      geo_index = if y == 0
                    geo_index = x * 16807
                  elsif x == 0
                    geo_index = y * 48271
                  else
                    geo_index =  map[y][x-1] * map[y-1][x]
                  end
      map[y][x] = erosion_level(geo_index)
    end
  end

  map[TARGET_Y][TARGET_X] = erosion_level(0)

  map
end

def region_type_map
  erosion_map.map do |row|
    row.map do |erosion_level|
      region_type(erosion_level)
    end
  end
end

def erosion_level(geo_index)
  (geo_index + DEPTH) % EROSION_CONST
end

def region_type(erosion_level)
  erosion_level % 3
end

def risk(erosion_level)
  case region_type(erosion_level)
  when ROCKY then 0
  when WET then 1
  when NARROW then 2
  else raise "bad region #{region}"
  end
end

def viz(map)
  puts(map.map do |row|
    row.map do |erosion_level|
      case region_type(erosion_level)
      when ROCKY then "."
      when WET then "="
      when NARROW then "|"
      end
    end.join
  end)
end

def part1
  map = erosion_map

  viz(map)

  risk = map.slice(0..TARGET_Y).reduce(0) do |sum, row|
    sum + row.slice(0..TARGET_X).reduce(0) do |sum, region|
      sum + risk(region)
    end
  end
  puts "Risk = #{risk}"
end

def tools_for(x, y, region_type)
  if x == 0 && y == 0
    [TORCH]
  elsif x == TARGET_X && y == TARGET_Y
    [TORCH]
  else
    PERMITTED_TOOLS[region_type]
  end
end

def adjacent_coords(x, y)
  [
    [x, y - 1],
    [x + 1, y],
    [x, y + 1],
    [x - 1, y]
  ]
end

def create_graph
  graph = {}

  map = region_type_map
  map.each_with_index do |row, y|
    row.each_with_index do |region_type, x|
      tools_for(x, y, region_type).each do |t|
        edges = {}

        adjacent_coords(x, y).each do |x1, y1|
          next if x1 < 0 || y1 < 0 || !map[y1] || !map[y1][x1]

          tools_for(x1, y1, map[y1][x1]).each do |t1|
            edges[[x1, y1, t1]] = MOVE_TIME + (t == t1 ? 0 : SWITCH_TIME)
          end
        end

        graph[[x, y, t]] = edges
      end
    end
  end

  graph
end

def part2
  graph = create_graph

  start = [0, 0, TORCH]
  stop = [TARGET_X, TARGET_Y, TORCH]
  finder = ShortestPath::Finder.new(start, stop).tap do |shortest_path|
    shortest_path.ways_finder = Proc.new { |node| graph[node] }
  end

  finder.timeout = 60

  path = finder.path

  time = 2 + (1...path.length).reduce(0) do |sum, i|
    sum + graph[path[i-1]][path[i]]
  end

  p path
  puts "Time = #{time}"
end

#part1
part2
