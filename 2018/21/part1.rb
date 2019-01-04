def run_program(a)
  verify_bitwise
  puts main_program(a)
end

def verify_bitwise
  loop do
    d = 123
    d &= 456
    break if d == 72
  end
end

def main_program(a)
  d = 0 # 5

  count = 0

  b = d | 65536 # 6
  d = 4921097 #7

  loop do
    e = b & 255 # 8
    d += e # 9

    d = d & 16777215 # 10
    d = d * 65899 # 11
    d = d & 16777215 # 12

    count += 9 # 6-12 above, 13-14 below

    puts "a=#{a}, b=#{b}, d=#{d}, count=#{count}"

    if 256 > b # 13, 14
      puts "a=#{a}, b=#{b}, d=#{d}, count=#{count}"
      return
      # 16, 28-30
      if d == a
        return count
      else
        b = d | 65536 # 6
        d = 4921097 #7
      end
    else # 15
      count += 2

      e = 0 # 17
      loop do # 18-25
        count += 8

        f = (e + 1)*256
        if f > b
          b = e + d
          break
        else
          e += 1
        end
      end
    end
  end
end

run_program(ARGV[0].to_i)
