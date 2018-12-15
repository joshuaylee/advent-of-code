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

def init_grid(coords)
  max_x = coords.keys.map(&:first).max
  max_y = coords.keys.map(&:last).max

  grid = (0..max_x).map do |x|
    [nil] * (max_y + 1)
  end

  coords.each do |(x, y), index|
    grid[x][y] = index
  end

  grid
end

def grow_clusters(coords, grid)
  added_coords = {}

  coords.each do |(x, y), cluster|
    [
      [x-1, y],
      [x+1, y],
      [x, y-1],
      [x, y+1]
    ].each do |neighbor_x, neighbor_y|
      next if neighbor_x < 0 || neighbor_y < 0 || neighbor_x >= grid.length || neighbor_y >= grid[0].length
      neighbor = point_at(grid, neighbor_x, neighbor_y)
      next if !neighbor.nil?
      xy = [neighbor_x, neighbor_y]
      if added_coords[xy].nil?
        added_coords[xy] = cluster
      elsif added_coords[xy] != cluster
        added_coords[xy] = 0
      end
    end
  end

  added_coords
end

def update_grid(grid, new_coords)
  new_coords.each do |(x, y), cluster|
    grid[x][y] = cluster
  end
end

def point_at(grid, x, y)
  col = grid[x]
  col[y] if col
end

def compute_largest_cluster2(coords, grid)
  # infinite are ones along the edge
  infinite = grid.first +
    grid.last +
    (0...grid.length).map { |x| grid[x][0] } +
    (0...grid.length).map { |x| grid[x][grid[0].length-1] }
  infinite = infinite.uniq

  p infinite.sort
  non_infinite = (coords.values - infinite).sort
  p non_infinite

  areas = non_infinite.map do |c|
    [c, grid.flatten.count { |x| x == c }]
  end.to_h

  puts "Areas = #{areas.inspect}"
  puts "Largest area = #{areas.values.max}"
end

def grid_str(grid)
  (0...grid[0].length).map do |y|
    (0...grid.length).map do |x|
      cluster = grid[x][y]
      cluster ? cluster.to_s.rjust(2).colorize(color_for(cluster)) : " -"
    end.join + "\n"
  end.join + "\n"
end

def color_for(cluster)
  @colors ||= Hash.new do |h, clust|
    h[clust] = ColorizedString.colors[clust.to_i * 2 % ColorizedString.colors.length]
  end
  @colors[cluster]
end

def solve
  coords = read_coordinates("input.txt")
  orig_coords = coords.dup
  grid = init_grid(coords)

  print "\nGrowing clusters"
  loop do
    print "."
    new_coords = grow_clusters(coords, grid)
    break if new_coords.empty?
    update_grid(grid, new_coords)
    coords = new_coords
  end

  puts "\nComputing largest cluster..."
  puts grid_str(grid)
  compute_largest_cluster2(orig_coords, grid)
end

solve
