require 'pry'

DEPTH = ARGV[0].to_i
TARGET_X = ARGV[1].to_i
TARGET_Y = ARGV[2].to_i
EROSION_CONST = 20183
PADDING = (ARGV[3] || 0).to_i

ROCKY = 0
WET = 1
NARROW = 2

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

part1
