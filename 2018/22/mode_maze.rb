require 'pry'

DEPTH = ARGV[0].to_i
TARGET_X = ARGV[1].to_i
TARGET_Y = ARGV[2].to_i
EROSION_CONST = 20183

ROCKY = 0
WET = 1
NARROW = 2

def erosion_map
  map = []

  (0..TARGET_Y).each do |y|
    row = Array.new(TARGET_X + 1)
    map.push(row)

    (0..TARGET_X).each do |x|
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

  risk = map.reduce(0) do |sum, row|
    sum + row.reduce(0) do |sum, region|
      sum + risk(region)
    end
  end
  puts "Risk = #{risk}"
end

part1
