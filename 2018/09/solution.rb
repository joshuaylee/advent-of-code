Node = Struct.new(:marble, :cw, :ccw)

def high_score(players, marbles)
  current_marble = Node.new(0, nil, nil)
  current_marble.cw = current_marble
  current_marble.ccw = current_marble

  scores = Hash.new(0)
  player = 1

  (1..marbles).each do |marble|
    if marble % 23 == 0
      scores[player] += marble

      remove_marble = current_marble
      7.times { remove_marble = remove_marble.ccw }
      scores[player] += remove_marble.marble

      remove_marble.ccw.cw = remove_marble.cw
      remove_marble.cw.ccw = remove_marble.ccw
      current_marble = remove_marble.cw
    else
      new_marble = Node.new(marble, current_marble.cw.cw, current_marble.cw)
      new_marble.cw.ccw = new_marble
      new_marble.ccw.cw = new_marble
      current_marble = new_marble
    end

    player += 1
    player = 1 if player > players
  end

  scores.values.max
end

puts "Part 1"
puts "High score = #{high_score(9, 25)}"
puts "High score = #{high_score(10, 1618)}"
puts "High score = #{high_score(13, 7999)}"
puts "High score = #{high_score(17, 1104)}"
puts "High score = #{high_score(21, 6111)}"
puts "High score = #{high_score(30, 5807)}"
puts "High score = #{high_score(463, 71787)}"

puts "Part 2"
puts "High score = #{high_score(463, 71787 * 100)}"
