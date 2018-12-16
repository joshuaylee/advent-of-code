def init_grid(serial_number)
  grid = (0...300).map { Array.new(300) }
  calculate_power(grid, serial_number)
  grid
end

def calculate_power(grid, serial_number)
  (0...300).each do |x|
    (0...300).each do |y|
      grid[x][y] = power_at(x + 1, y + 1, serial_number)
    end
  end
end

def power_at(x, y, serial_number)
  rack_id = x + 10
  power_level = rack_id * y + serial_number
  power_level *= rack_id
  power_level = power_level.to_s.slice(-3).to_i
  power_level - 5
end

def find_max_power_3x3(grid)
  puts "Finding max power 3x3..."

  max_x = nil
  max_y = nil
  max_power = nil

  n = 3
  (0...(300-n)).each do |x|
    (0...(300-n)).each do |y|
      cur_power = total_power_at(x, y, n, grid)
      if max_power.nil? || cur_power > max_power
        max_x = x
        max_y = y
        max_power = cur_power
      end
    end
  end

  {
    x: max_x + 1,
    y: max_y + 1,
    n: n,
    total_power: max_power
  }
end

def total_power_at(x, y, n, grid)
  (0...n).reduce(0) do |memo, offset|
    memo + grid[x + offset].slice(y, n).reduce(:+)
  end
end

def find_max_power_overall(grid)
  memo = (0...300).map { [0] * 300 }
  max = {}

  (1..300).each do |n|
    print "Finding max power n=#{n.to_s.ljust(5)}\r"

    (0...(300-n)).each do |x|
      (0...(300-n)).each do |y|
        update_memo(memo, x, y, n, grid)
        if !max[:total_power] || memo[x][y] > max[:total_power]
          max[:x] = x + 1
          max[:y] = y + 1
          max[:n] = n
          max[:total_power] = memo[x][y]
        end
      end
    end
  end

  max
end

# memo[x][y] has total power for (n-1)x(n-1) square.
# update the value for nxn square
def update_memo(memo, x, y, n, grid)
  add_right = grid[x + n - 1].slice(y, n).reduce(:+)
  add_bottom = (0...n).reduce(0) do |sum, x_offset|
    sum + grid[x + x_offset][y + n - 1]
  end
  memo[x][y] += add_right + add_bottom
end


def part1(serial_number)
  puts "Part 1"

  grid = init_grid(serial_number)
  max_3x3 = find_max_power_3x3(grid)
  puts "For grid serial number #{serial_number}, the largest total #{max_3x3[:n]}x#{max_3x3[:n]} square has " \
    "a top-left corner of #{max_3x3[:x]},#{max_3x3[:y]} " \
    "(with a total power of #{max_3x3[:total_power]})"
end

def part2(serial_number)
  puts "Part 2"

  grid = init_grid(serial_number)
  max_nxn = find_max_power_overall(grid)
  identifier = [max_nxn[:x], max_nxn[:y], max_nxn[:n]].join(",")
  puts "For grid serial number #{serial_number}, the largest total square "\
    "(with a total power of #{max_nxn[:total_power]}) "\
    "is #{max_nxn[:n]}x#{max_nxn[:n]} "\
    "and has a top-left corner of #{max_nxn[:x]},#{max_nxn[:y]} "\
    "so its identifier is #{identifier}"
end

serial_number = ARGV[0].to_i
part1(serial_number)
part2(serial_number)
