require 'set'

def read_file(path)
  points = []
  velocities = []
  File.open(ARGV[0]).each do |line|
    match = line.match(/position=<(.+),(.+)> velocity=<(.+),(.+)>/)
    points << [match[1].to_i, match[2].to_i]
    velocities << [match[3].to_i, match[4].to_i]
  end

  [points, velocities]
end

def advance_points(points, velocities, rewind: false)
  points.each_with_index do |point, i|
    points[i][0] += velocities[i][0] * (rewind ? -1 : 1)
    points[i][1] += velocities[i][1] * (rewind ? -1 : 1)
  end
end

def calc_spread(points)
  xs = points.map(&:first)
  ys = points.map(&:last)
  (xs.max - xs.min).abs * (ys.max - ys.min).abs
end

def write_svg(path, points)
  xs = points.map(&:first)
  ys = points.map(&:last)

  top = xs.min
  left = ys.min
  width = xs.max - xs.min
  height = ys.max - ys.min

  file = File.open(path, "w")
  file.write("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"#{top} #{left} #{width} #{height}\">")
  file.write(points.map{ |x,y| "<circle cx='#{x}' cy='#{y}' r='0.5' />" }.join("\n"))
  file.write("</svg")
  file.close
end

points, velocities = read_file(ARGV[0])

spread_prev = calc_spread(points)
time = 0
loop do
  time += 1
  advance_points(points, velocities)
  spread = calc_spread(points)
  puts spread.to_s.rjust(12)

  break if spread > spread_prev
  spread_prev = spread
end

# Go back 1 frame
puts "Message after #{time-1} seconds"
advance_points(points, velocities, rewind: true)

write_svg("message.svg.html", points)
