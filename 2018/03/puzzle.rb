FABRIC_WIDTH = 1000
FABRIC_LENGTH = 1000

class Claim
  def self.from_line(line)
    match = line.match(/\#(\d+) @ (\d+),(\d+): (\d+)x(\d+)/)
    new(*match.to_a.slice(1,5))
  end

  attr_reader :id, :left, :top, :width, :length

  def initialize(id, left, top, width, length)
    @id = id
    @left = left.to_i
    @top = top.to_i
    @width = width.to_i
    @length = length.to_i
  end
end

def read_claims
  File.open("input.txt").each_with_object([]) do |line, claims|
    claims << Claim.from_line(line.strip)
  end
end

def each_fabric_position(claim, fabric)
  off_y = 0
  while off_y < claim.length
    off_x = 0
    while off_x < claim.width
      position = ((off_x + claim.left) * FABRIC_WIDTH) + (off_y + claim.top)
      yield(position, fabric, claim)
      off_x += 1
    end
    off_y += 1
  end
end

def apply_claim(claim, fabric)
  each_fabric_position(claim, fabric) do |position, _fabric, _claim|
    fabric[position] += 1
  end
end

def overlap?(claim, fabric)
  overlap = false
  each_fabric_position(claim, fabric) do |position, _fabric, _claim|
    overlap = overlap || (fabric[position] > 1)
  end
  overlap
end

def part1
  fabric = [0] * (FABRIC_WIDTH * FABRIC_LENGTH)
  read_claims.each do |claim|
    apply_claim(claim, fabric)
  end

  fabric.count { |n| n > 1 }
end

def part2
  fabric = [0] * (FABRIC_WIDTH * FABRIC_LENGTH)
  claims = read_claims

  claims.each do |claim|
    apply_claim(claim, fabric)
  end

  claims.detect do |claim|
    !overlap?(claim, fabric)
  end
end

puts "Part 1 Answer: #{part1}"

puts "Part 1 Answer: #{part2.id}"
