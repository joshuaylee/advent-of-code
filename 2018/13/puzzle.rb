require 'set'

Cart = Struct.new(:x, :y, :dir, :prev_decision)

def read_input(file)
  File.read(file).split("\n")
end

def get_carts(input)
  carts = []
  input.each_with_index do |line, y|
    line.chars.each_with_index do |ch, x|
      next unless %w(> < ^ v).include?(ch)
      carts << Cart.new(x, y, ch, :turn_right)
    end
  end
  carts
end

def get_track(input)
  input.map do |line|
    line.
      gsub(">", "-").
      gsub("<", "-").
      gsub("^", "|").
      gsub("v", "|").
      freeze
  end
end

def turn_left(cart)
  cart.dir = {
    ">" => "^",
    "^" => "<",
    "<" => "v",
    "v" => ">"
  }[cart.dir]
  straight(cart)
end

def turn_right(cart)
  cart.dir = {
    ">" => "v",
    "v" => "<",
    "<" => "^",
    "^" => ">"
  }[cart.dir]
  straight(cart)
end

def turn(cart, track_spot)
  case cart.dir + track_spot
  when *%w(>/ ^\\ </ v\\) then turn_left(cart)
  when *%w(>\\ v/ <\\ ^/) then turn_right(cart)
  else raise "invalid combo: #{cart.dir}#{track_spot}"
  end
end

def handle_intersection(cart)
  cart.prev_decision = {
    :turn_right => :turn_left,
    :turn_left => :straight,
    :straight => :turn_right
  }[cart.prev_decision]
  send(cart.prev_decision, cart)
end

def straight(cart)
  case cart.dir
  when ">" then cart.x += 1
  when "<" then cart.x -= 1
  when "v" then cart.y += 1
  when "^" then cart.y -= 1
  end
end

def update_position(cart, track)
  track_spot = track[cart.y][cart.x]
  case track_spot
  when "\\", "/" then turn(cart, track_spot)
  when "+" then handle_intersection(cart)
  when "-", "|" then straight(cart)
  else raise "bad spot #{cart.inspect}"
  end
end

def build_position_hash(carts)
  carts.each_with_object({}) { |c, h| h[[c.x, c.y]] = c }.to_h
end

def ordered_carts(carts)
  hash = carts.map { |c| [c.y*1000 + c.x, c] }.to_h
  hash.keys.sort.map { |k| hash[k] }
end

def simulate(file_path, &on_collision)
  input = read_input(ARGV[0])
  carts = get_carts(input)
  track = get_track(input)

  keep_going = true
  while keep_going
    position_hash = build_position_hash(carts)
    ordered_carts(carts).each do |cart|
      position_hash.delete([cart.x, cart.y])
      update_position(cart, track)
      new_pos = [cart.x, cart.y]

      if position_hash.key?(new_pos)
        keep_going = on_collision.call(new_pos, cart, position_hash, carts)
        break if !keep_going
      else
        position_hash[new_pos] = cart
      end
    end

    break if carts.length < 2
  end

  puts "Remaining Carts: "
  puts carts.map { |c| "<#{c.x},#{c.y}>" }
end

def part1
  simulate(ARGV[0]) do |collision_pos, _cart, _position_hash, _carts|
    puts "Collision at #{collision_pos.inspect}"
    false
  end
end

def part2
  simulate(ARGV[0]) do |collision_pos, cart, position_hash, carts|
    other_cart = position_hash.delete(collision_pos)
    carts.delete(cart)
    carts.delete(other_cart)
    puts "Collision at #{collision_pos.inspect}, #{carts.length} carts left"
    true
  end
end

puts "Part 1"
part1

puts "\nPart 2"
part2
