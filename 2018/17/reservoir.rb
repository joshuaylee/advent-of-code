require 'set'

INPUT_FILE = ARGV[0]
WATER_LIMIT = (ARGV[1] || 50000).to_i

@waterfalls = Set.new
@water_locations = Set.new
@clay_locations = Set.new

def load_clay_locations(file)
  clay = Set.new

  File.open(file).each do |line|
    tokens = line.strip.match(/^([xy])=(\d+), .=(\d+)\.\.(\d+)/)
    next if tokens.nil?

    xrange = [tokens[2].to_i]
    yrange = (tokens[3].to_i..tokens[4].to_i)
    orientation = tokens[1]

    if orientation == "y"
      tmp = xrange
      xrange = yrange
      yrange = tmp
    end

    xrange.each do |x|
      yrange.each do |y|
        @clay_locations.add([x,y])
      end
    end
  end
end

def max_depth
  @max_depth ||= @clay_locations.max_by(&:last).last
end

def clay?(x, y)
  @clay_locations.include?([x, y])
end

def water?(x, y)
  @water_locations.include?([x, y])
end

def waterfall?(x, y)
  @waterfalls.include?([x,y])
end

def water_reaches(x, y)
  @water_locations.add([x, y])
end

def flow_down(x, y)
  return if waterfall?(x, y)
  @waterfalls.add([x, y])

  return if @water_locations.size > WATER_LIMIT

  until clay?(x, y+1) || y >= max_depth
    y += 1
    water_reaches(x, y)
  end

  fill_up(x, y) if y < max_depth
end

def fill_up(x, y)
  loop do
    lx, left = flow_horiz(x, y, -1)
    rx, right = flow_horiz(x, y, 1)

    if left == :clay && right == :clay
      y -= 1
    else
      flow_down(lx, y) if left == :gravity
      flow_down(rx, y) if right == :gravity
      break if !contained?(x, y)
      y -= 1
    end
  end
end

def flow_horiz(x, y, delta)
  return false if @water_locations.size > WATER_LIMIT

  stop_reason = loop do
    x += delta
    break :clay if clay?(x, y)

    water_reaches(x, y)
    if waterfall?(x, y)
      break :gravity
    elsif !clay?(x, y + 1) && !water?(x, y + 1) # new waterfall
      break :gravity
    end
  end

  [x, stop_reason]
end

def contained?(x, y)
  orig_x = x

  left = while water?(x, y)
    x -= 1
    break true if clay?(x, y)
  end

  x = orig_x

  right = while water?(x, y)
    x += 1
    break true if clay?(x, y)
  end

  left && right
end

def part1
  load_clay_locations(INPUT_FILE)
  flow_down(500, 0)

  min_depth = @clay_locations.min_by(&:last).last
  water_count = @water_locations.count { |(_x, y)| y >= min_depth && y <= max_depth }

  puts "min_depth = #{min_depth}"
  puts "max_depth = #{max_depth}"
  puts "The total number of tiles the water can reach is #{water_count}"
end

def write_svg
  top = -0.5
  left = @clay_locations.min_by(&:first).first - 2
  width = @clay_locations.max_by(&:first).first - left + 4
  height = max_depth + 1

  svg_name = "viz-" + Time.now.strftime("%Y%M%d-%H%m%S") + ".html"
  svg = File.open(svg_name, "w")
  svg.write("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"#{left} #{top} #{width} #{height}\">\n")
  svg.write("<rect fill='rgb(190, 174, 116)' x='#{left}' y='#{top}' width='#{width}' height='#{height}'/>\n")

  File.open(INPUT_FILE).each do |line|
    tokens = line.strip.match(/^([xy])=(\d+), .=(\d+)\.\.(\d+)/)
    next if tokens.nil?

    if tokens[1] == "x"
      x1 = x2 = tokens[2].to_i
      y1 = tokens[3].to_i - 0.5
      y2 = tokens[4].to_i + 0.5
    else
      y1 = y2 = tokens[2].to_i
      x1 = tokens[3].to_i - 0.5
      x2 = tokens[4].to_i + 0.5
    end

    svg.write("<line x1='#{x1}' y1='#{y1}' x2='#{x2}' y2='#{y2}' stroke='rgb(108, 87, 14)' />\n")
  end

  @water_locations.each do |(x, y)|
    svg.write("<rect x='#{x-0.5}' y='#{y-0.5}' width='1' height='1' stroke='blue' fill='rgb(97, 174, 224)' stroke-width='0'/>")
  end

  svg.write("</svg>\n")
  svg.close

  `open #{svg_name}`
end

part1
write_svg
