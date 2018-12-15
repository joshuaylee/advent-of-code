def char_freq(string)
  string.chars.each_with_object(Hash.new(0)) do |c, freqs|
    freqs[c] += 1
  end
end

def part1
  twice = 0
  thrice = 0

  file = File.open("input.txt")
  file.each do |line|
    char_freqs = char_freq(line.strip).values
    twice += 1 if char_freqs.include?(2)
    thrice += 1 if char_freqs.include?(3)
  end

  twice * thrice
end

def calculate_common_chars(line1, line2)
  common = []
  line1.chars.each_with_index do |c, i|
    common << c if c == line2[i]
  end
  common
end

def part2
  lines = File.read("input.txt").split("\n").sort
  line_size = lines.first.size
  num_lines = lines.count

  index = 1
  while index < num_lines
    line1 = lines[index-1]
    line2 = lines[index]
    common_chars = calculate_common_chars(line1, line2)
    break common_chars if common_chars.count == line_size - 1

    index += 1
  end
end

puts "Part 1 Answer = #{part1}"
puts "Part 2 Answer = #{part2.join}"
