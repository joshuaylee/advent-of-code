def each_sample(file)
  e = File.open(file).each_line
  loop do
    reg_pre, instr, reg_post, _blank =  e.next, e.next, e.next, e.next
    break unless reg_pre.match(/^Before:/)

    yield(parse_regs(reg_pre), parse_instr(instr), parse_regs(reg_post))
  end
end

def parse_regs(str)
  str.match(/\[(.*)\]/)[1].split(", ").map(&:to_i)
end

def parse_instr(str)
  str.split.map(&:to_i)
end

ops = {
  addr: -> (r,a,b,c) { r[c] = r[a] + r[b] },
  addi: -> (r,a,b,c) { r[c] = r[a] + b },
  mulr: -> (r,a,b,c) { r[c] = r[a] * r[b] },
  muli: -> (r,a,b,c) { r[c] = r[a] * b },
  banr: -> (r,a,b,c) { r[c] = r[a] & r[b] },
  bani: -> (r,a,b,c) { r[c] = r[a] & b },
  borr: -> (r,a,b,c) { r[c] = r[a] | r[b] },
  bori: -> (r,a,b,c) { r[c] = r[a] | b },
  setr: -> (r,a,b,c) { r[c] = r[a] },
  seti: -> (r,a,b,c) { r[c] = a },
  gtir: -> (r,a,b,c) { r[c] = a > r[b] ? 1 : 0 },
  gtri: -> (r,a,b,c) { r[c] = r[a] > b ? 1 : 0 },
  gtrr: -> (r,a,b,c) { r[c] = r[a] > r[b] ? 1 : 0 },
  eqir: -> (r,a,b,c) { r[c] = a == r[b] ? 1 : 0 },
  eqri: -> (r,a,b,c) { r[c] = r[a] == b ? 1 : 0 },
  eqrr: -> (r,a,b,c) { r[c] = r[a] == r[b] ? 1 : 0 }
}.freeze

num_samples = 0
each_sample(ARGV[0]) do |reg_pre, instr, reg_post|
  acts_like_count = ops.count do |opcode, proc|
    regs = reg_pre.dup
    proc.call(regs, *instr.slice(1,3))
    regs == reg_post
  end

  num_samples += 1 if acts_like_count >= 3
end

p num_samples
