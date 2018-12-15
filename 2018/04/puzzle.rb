class Analyzer
  def get_tallies
    @tallies = {}

    current_guard = nil
    asleep_at = nil
    awake_at = nil

    lines = File.read("input.txt.sort").split("\n")
    lines.each do |line|
      match = line.match(/\[\d\d\d\d-\d\d-\d\d \d\d:(\d\d)\] (.*)/)

      current_minute = match[1].to_i
      current_event = match[2]

      if (new_guard = get_new_guard(current_event))
        current_guard = new_guard
        asleep_at = nil
        awake_at = nil
      elsif current_event == "falls asleep"
        asleep_at = current_minute
      elsif current_event == "wakes up"
        awake_at = current_minute
        record_nap(current_guard, asleep_at, awake_at)
      else
        raise "Couldn't parse: #{line}"
      end
    end

    @tallies
  end

  private

  def get_new_guard(event)
    event.match(/Guard #(\d+) begins shift/).to_a[1]
  end

  def record_nap(guard, asleep_at, awake_at)
    @tallies[guard] ||= {
      total: 0,
      minute: (0..59).map { |m| [m, 0] }.to_h
    }

    @tallies[guard][:total] += awake_at - asleep_at

    (asleep_at..awake_at).each do |minute|
      @tallies[guard][:minute][minute] += 1
    end
  end
end

def sleepiest_minutes(totals_by_minute)
  max_minute = totals_by_minute.values.max
  totals_by_minute.select { |h, k| k == max_minute }
end

tallies = Analyzer.new.get_tallies

puts "*** Part 1 Answer"

guard_id, guard_data = tallies.max_by do |_guard, data|
  data[:total]
end

sleepiest_minutes = sleepiest_minutes(guard_data[:minute]).keys

puts "sleepiest guard = #{guard_id}"
puts "sleepiest minutes = #{sleepiest_minutes}"
puts "potential answers = #{sleepiest_minutes.map { |m| m * guard_id.to_i }}"

puts "\n"

puts "*** Part 2 Answer"

guard_id, guard_data = tallies.max_by do |guard, data|
  sleepiest_minutes = sleepiest_minutes(data[:minute])
  sleepiest_minutes.values.first
end

sleepiest_minutes = sleepiest_minutes(guard_data[:minute]).keys

puts "sleepiest guard = #{guard_id}"
puts "sleepiest minutes = #{sleepiest_minutes}"
puts "potential answers = #{sleepiest_minutes.map { |m| m * guard_id.to_i }}"

