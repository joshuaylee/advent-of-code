def part1(next_ten_after)
  recipes = [3, 7]
  elf1 = 0
  elf2 = 1

  while recipes.length < next_ten_after + 10
    sum = recipes[elf1] + recipes[elf2]
    sum.to_s.chars.each do |new_recipe|
      recipes.push(new_recipe.to_i)
    end

    elf1 = (elf1 + 1 + recipes[elf1]) % recipes.length
    elf2 = (elf2 + 1 + recipes[elf2]) % recipes.length

    print "#{recipes.length.to_s.ljust(10)}\r"
  end

  scores = recipes.slice(next_ten_after, 10).join
  puts "After #{next_ten_after} recipes, the scores of the next ten are #{scores}."
end

def part2(seek_pattern)
  recipes = [3, 7]
  elf1 = 0
  elf2 = 1

  tail = recipes.dup
  seek = seek_pattern.chars.map(&:to_i)

  loop do
    sum = recipes[elf1] + recipes[elf2]

    keep_going = sum.to_s.chars.each do |new_recipe|
      recipe = new_recipe.to_i

      recipes.push(recipe)
      tail.push(recipe)
      tail.shift if tail.length > seek.length

      break if tail == seek
    end

    break unless keep_going

    elf1 = (elf1 + 1 + recipes[elf1]) % recipes.length
    elf2 = (elf2 + 1 + recipes[elf2]) % recipes.length

    print "#{recipes.length.to_s.ljust(10)}\r"
  end

  puts "#{seek_pattern} first appears after #{recipes.length - seek.length} recipes"
end

input = ARGV[0]
part1(input.to_i)
part2(input)
