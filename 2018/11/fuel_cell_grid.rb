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

def find_max_power_nxn(grid, n)
  max_x = nil
  max_y = nil
  max_power = nil

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

serial_number = ARGV[0].to_i
grid = init_grid(serial_number)
max_3x3 = find_max_power_nxn(grid, 3)
puts "For grid serial number #{serial_number}, the largest total #{max_3x3[:n]}x#{max_3x3[:n]} square has " \
  "a top-left corner of #{max_3x3[:x]},#{max_3x3[:y]} " \
  "(with a total power of #{max_3x3[:total_power]})"
