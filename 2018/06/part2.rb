#require 'pry'
require 'colorize'
require 'colorized_string'

def read_coordinates(file)
  coords = {}
  index = 1
  File.open(file).each do |line|
    point = line.strip.split(", ").map(&:to_i)
    coords[point] = index
    index += 1
  end
  coords
end

def grid_str(coords, grid)
  (0...grid[0].length).map do |y|
    (0...grid.length).map do |x|
      if coords.key?([x, y])
        "***".red
      elsif grid[x][y] < 10_000
        "###".green
      else
        " - ".blue
      end
    end.join + "\n"
  end.join + "\n"
end

def compute_total_distances(coords)
  max_x = coords.keys.map(&:first).max
  max_y = coords.keys.map(&:last).max

  (0..max_x).map do |x|
    (0..max_y).map do |y|
      total_distance(x, y, coords)
    end
  end
end

def total_distance(x, y, coords)
  coords.keys.reduce(0) { |total, (x2, y2)| total + manhattan_distance(x, y, x2, y2) }
end

def manhattan_distance(x1, y1, x2, y2)
  (x1 - x2).abs + (y1 - y2).abs
end

def compute_region_size(distance_matrix)
  distance_matrix.flatten.count { |d| d < 10_000 }
end

def solve
  coords = read_coordinates("input.txt")

  puts "Computing distances..."
  distance_matrix = compute_total_distances(coords)

  puts "Here's what I got..."
  puts grid_str(coords, distance_matrix)

  puts "Computing size..."
  puts compute_region_size(distance_matrix)
end

solve
