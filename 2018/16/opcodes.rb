require 'set'

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

def op_names
  op_procs.keys
end

def perform_op(op_name, a, b, c, registers)
  @op_procs[op_name].call(registers, a, b, c)
end

def sample_acts_like_op?(op_name, instr, reg_pre, reg_expected)
  regs = reg_pre.dup
  perform_op(op_name, *instr.slice(1,3), regs)
  regs == reg_expected
end

def part1
  num_samples = 0
  each_sample(ARGV[0]) do |reg_pre, instr, reg_post|
    potential_ops = op_names.count do |op_name|
      sample_acts_like_op?(op_name, instr, reg_pre, reg_post)
    end
    num_samples += 1 if potential_ops >= 3
  end

  puts "#{num_samples} samples act like 3 or more ops"
end

def eliminate_mappings(map, opcode)
  op_name = map[opcode].first
  map.each_with_index do |potential_ops, opcode|
    next if potential_ops.one?

    potential_ops.delete(op_name)
    eliminate_mappings(map, opcode) if potential_ops.one?
  end
end

def map_opcodes(file)
  map = op_names.count.times.map { op_names.to_set }

  each_sample(ARGV[0]) do |reg_pre, instr, reg_post|
    op_names.each do |op_name|
      opcode = instr.first
      next if sample_acts_like_op?(op_name, instr, reg_pre, reg_post)

      map[opcode].delete(op_name)
      eliminate_mappings(map, opcode) if map[opcode].one?
    end
  end

  map.map(&:first)
end

def part2
  opcodes = map_opcodes(ARGV[0])
  puts "Mapped opcodes"
  opcodes.each_with_index do |op_name, opcode|
    puts "#{opcode}: #{op_name}"
  end

  regs = [0, 0, 0, 0]
  File.open(ARGV[1]).each do |line|
    instr = parse_instr(line.strip)
    op_name = opcodes[instr[0]]
    perform_op(op_name, *instr.slice(1,3), regs)
  end
  puts "After test program: #{regs.inspect}"
end

part1
part2

