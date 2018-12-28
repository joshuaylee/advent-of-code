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

input = ARGV[0].to_i
part1(input)
