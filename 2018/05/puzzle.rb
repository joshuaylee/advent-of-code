
def reactable?(unit1, unit2)
  unit1 != unit2 && unit1.downcase == unit2.downcase
end

def react(polymer)
  index = -1
  units = []

  polymer.chars.each do |unit|
    if index > -1 && reactable?(unit, units[index])
      index -= 1
    else
      index += 1
      units[index] = unit
    end
  end

  units.slice(0, index+1)
end

def sample
  result = react("dabAcCaCBAcCcaDA")
  puts "Sample"
  puts result.join
  puts result.length
end

def part1
  polymer = File.read("input.txt").strip
  result = react(polymer)
  puts "Part1"
  puts result.join
  puts result.length
end

def part2
  polymer = File.read("input.txt").strip

  unit_types = polymer.downcase.chars.uniq

  unit_types_with_result = unit_types.map do |unit_type|
    new_polymer = polymer.gsub(unit_type, '').gsub(unit_type.upcase, '')
    [unit_type, react(new_polymer).length]
  end

  puts "Part2"
  puts unit_types_with_result.min_by(&:last).last
end

sample

part1

part2
