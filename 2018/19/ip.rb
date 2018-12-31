require 'set'

def run_program(file, reg0_start=0)
  regs = [0] * 6
  regs[0] = reg0_start
  ip = 0

  program = File.open(file).readlines.map(&:strip)
  ip_reg = ip_instr(program.first)
  program.shift
  program = program.map { |line| parse_instr(line) }

  loop do
    regs[ip_reg] = ip

    instr = program[ip]
    break unless instr

    reg0 = regs.dup
    perform_op(*instr, regs)
    #puts "ip#{ip} #{reg0.inspect} #{instr} #{regs.inspect}"

    ip = regs[ip_reg]
    ip += 1
    #sleep 1
  end

  puts "After test program: #{regs.inspect}"
end

def ip_instr(line)
  match = line.match(/#ip (\d)/)
  match && match[1].to_i
end

def parse_instr(str)
  tokens = str.split
  tokens[0] = tokens[0].to_sym
  (1..3).each { |i| tokens[i] = tokens[i].to_i }
  tokens
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

def perform_op(op_name, a, b, c, registers)
  op_procs[op_name].call(registers, a, b, c)
end


run_program(ARGV[0], ARGV[1].to_i)
