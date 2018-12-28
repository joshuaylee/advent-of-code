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

def op_procs
  @op_procs ||= {
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
end

def opcodes
  op_procs.keys
end

def do_op(opcode, registers, a, b, c=nil)
  @op_procs[opcode].call(registers, a, b, c)
end

def sample_acts_like_op?(opcode, reg_pre, instr, reg_expected)
  regs = reg_pre.dup
  do_op(opcode, regs, *instr.slice(1,3))
  regs == reg_expected
end

def part1
  num_samples = 0
  each_sample(ARGV[0]) do |reg_pre, instr, reg_post|
    potential_ops = opcodes.count do |opcode|
      sample_acts_like_op?(opcode, reg_pre, instr, reg_post)
    end
    num_samples += 1 if potential_ops >= 3
  end

  puts "#{num_samples} samples act like 3 or more ops"
end

part1

