require 'set'

DURATION_ADJUSTMENT = 60
NUM_WORKERS = 5

steps = Set.new
step_requirements = Hash.new { |h,k| h[k] = Set.new }
step_requirement_of = Hash.new { |h,k| h[k] = Set.new }
step_durations = Hash.new { |h,k| h[k] = DURATION_ADJUSTMENT + (k.ord - 'A'.ord + 1) }

File.open(ARGV[0]).each do |line|
  match = line.match(/Step (.+) must be finished before step (.+) can begin\./)
  requirement = match[1]
  step = match[2]

  steps.add(step)
  steps.add(requirement)

  step_requirements[step].add(requirement)
  step_requirement_of[requirement].add(step)
end

WorkerJob = Struct.new(:step, :finish_at)

time = 0
queued_steps = steps - step_requirements.keys
current_jobs = Set.new
completed = Hash.new(false)
loop do
  current_jobs.each do |job|
    if time == job.finish_at
      step = job.step
      puts "#{time}: Finished #{step}"

      current_jobs.delete(job)
      completed[step] = true
      queued_steps += step_requirement_of[step].select do |s|
        step_requirements[s].all? { |req| completed[req] }
      end
    end
  end

  queued_steps.sort.first(NUM_WORKERS - current_jobs.size).each do |step|
    puts "#{time}: Starting #{step}"
    queued_steps.delete(step)
    current_jobs.add(WorkerJob.new(step, time + step_durations[step]))
  end

  break if current_jobs.empty?

  time += 1
end

puts time
