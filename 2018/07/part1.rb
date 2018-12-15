require 'set'

step_requirements = Hash.new { |h,k| h[k] = Set.new }
step_requirement_of = Hash.new { |h,k| h[k] = Set.new }
steps = Set.new

file = "input.txt"

File.open(file).each do |line|
  match = line.match(/Step (.+) must be finished before step (.+) can begin\./)
  requirement = match[1]
  step = match[2]

  steps.add(step)
  steps.add(requirement)

  step_requirements[step].add(requirement)
  step_requirement_of[requirement].add(step)
end

completed = []
candidates = steps - step_requirements.keys

loop do
  next_step = candidates.
    sort.
    detect { |c| step_requirements[c].all? { |req| completed.include?(req) } }

  completed.push(next_step)
  candidates = candidates.delete(next_step).union(step_requirement_of[next_step])

  break if candidates.empty?
end

puts completed.join
