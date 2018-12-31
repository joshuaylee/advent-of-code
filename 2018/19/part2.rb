def factor(r4, r2, _r5)
  print r2.to_s.ljust(7) + "\r"
  r4 % r2 == 0 ? r2 : nil

  #loop do # 3-11
  #  if r2 * r5 == r4 # 3-5
  #    return r2 # 7
  #  end
  #  r5 += 1 # 8

  #  break if r5 > r4 # 9-10
  #end
end

# 17-35
r4 = 10551326

r0 = 0 # answer
r2 = 1
r5 = 5

loop do
  # 2-11
  r5 = 1 # 2
  factor = factor(r4, r2, r5)
  if factor
    puts "#{r2} is a factor of #{r4}"
    r0 += factor
  end

  # 12
  r2 += 1

  break if r2 > r4
end

puts "answer = r0 = #{r0}"
