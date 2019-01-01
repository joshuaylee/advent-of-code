require 'pry'

class Mapper
  Room = Struct.new(:id, :x, :y, :n, :e, :s, :w)

  def initialize(file)
    @full_regex = File.read(file).strip
    @origin = new_room(0, 0)
    @rooms = { @origin.id => @origin }
  end

  def map
    raise unless full_regex[0] == '^'
    raise unless full_regex[-1] == '$'

    map_recursive(@origin, full_regex, true)

    @origin
  end

  private

  attr_reader :rooms, :full_regex
  def map_recursive(start_room, regex, debug=false)
    @memo ||= {}
    @memo[start_room.id + regex] ||= begin
      i = 0
      current = start_room
      while i < regex.length
        ch = regex[i]
        case ch
        when '^'
        when nil, '$'
          break
        when 'N', 'E', 'W', 'S'
          current = move(current, ch.downcase)
        when '('
          map_branches(current, regex.slice(i..-1))
          break
        else
          raise "Unexpected char at #{i}"
        end
        i += 1
      end
      current
    end
  end

  def map_branches(room, regex)
    parsing = parse_branches(regex)
    parsing[:branches].each do |branch|
      branch_room = map_recursive(room, branch)
      map_recursive(branch_room, parsing[:remainder])
    end
  end

  def parse_branches(regex)
    raise unless regex[0] == '('

    i = 1
    level = 0
    branches = [""]
    until regex[i].nil? || regex[i] == ")" && level == 0
      ch = regex[i]
      if ch == "|" && level == 0
        branches.push("")
      else
        branches.last.concat(ch)
        if ch == "("
          level += 1
        elsif ch == ")"
          level -= 1
        end
      end

      i += 1
    end

    { branches: branches, remainder: regex.slice(i+1..-1) }
  end

  def move(from, dir)
    to_x = case dir
           when "e" then from.x + 1
           when "w" then from.x - 1
           else from.x
           end
    to_y = case dir
           when "s" then from.y + 1
           when "n" then from.y - 1
           else from.y
           end

    to = find_or_create_room(to_x, to_y)

    to.send(opposite(dir) + "=", from)
    from.send(dir + "=", to)
  end

  def opposite(dir)
    case dir
    when "n" then "s"
    when "s" then "n"
    when "e" then "w"
    when "w" then "e"
    end
  end

  def find_or_create_room(x, y)
    id = room_id(x, y)
    rooms[id] ||= new_room(x, y)
  end

  def new_room(x, y)
    Room.new(room_id(x, y), x, y, nil, nil, nil, nil)
  end

  def room_id(x, y)
    "#{x},#{y}"
  end
end

class DistanceCalculator
  def initialize(origin)
    @origin = origin
  end

  def calculate
    edges = [@origin]
    distances = {}

    distance = 0
    while edges.any?
      distance += 1
      edges = edges.flat_map do |room|
        %i(n e s w).
          map { |dir| room.send(dir) }.
          compact.
          reject { |room| distances[room] }
      end
      edges.each { |r| distances[r] = distance }
    end

    distances
  end

  private
end

def part1
  mapper = Mapper.new(ARGV[0])
  origin = mapper.map
  distances = DistanceCalculator.new(origin).calculate
  room, distance = distances.max_by(&:last)
  puts "The furthest room is at <#{room.x}, #{room.y}> and is #{distance} doors away"
end

def part2
  mapper = Mapper.new(ARGV[0])
  origin = mapper.map
  distances = DistanceCalculator.new(origin).calculate
  count_dist_gt_1000 = distances.count { |_k, v| v >= 1000 }
  puts "#{count_dist_gt_1000} rooms have a shortest path from your current location that pass through at least 1000 doors"
end

part1
part2
