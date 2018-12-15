require 'set'

def part1
  frequency = 0
  File.open("input.txt").each do |line|
    change = line.strip.to_i
    frequency += change
  end
  frequency
end

def part2
  frequency = 0
  frequencies = Set.new([0])
  duplicate_frequency = nil

  file = File.open("input.txt")
  while duplicate_frequency.nil?
    file.rewind
    file.each do |line|
      change = line.strip.to_i
      frequency += change
      if frequencies.include?(frequency)
        duplicate_frequency = frequency
        break
      else
        frequencies.add(frequency)
      end
    end
  end

  duplicate_frequency
end

puts "Part 1 Answer: #{part1}"
puts "Part 1 Answer: #{part2}"

