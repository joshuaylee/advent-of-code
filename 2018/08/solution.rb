Node = Struct.new(:children, :metadata) do
  def value
    @value ||= \
      if children.empty?
        metadata.reduce(:+)
      else
        metadata.reduce(0) do |sum, child_index|
          child = children[child_index - 1]
          sum + (child && child.value).to_i
        end
      end
  end
end

class LicenseReader
  def initialize(file)
    @numbers = file.read.split
  end

  def read
    _index, root = read_node(0)
    root
  end

  private

  attr_reader :numbers

  def read_node(start)
    num_children = numbers[start].to_i
    num_metadata = numbers[start+1].to_i

    index = start + 2
    children = (1..num_children).map do
      index, node = read_node(index)
      node
    end

    metadata = numbers.slice(index, num_metadata).map(&:to_i)
    index += num_metadata

    [index, Node.new(children, metadata)]
  end
end

def bfs(root)
  nodes = [root]
  while !nodes.empty?
    nodes = nodes.reduce([]) do |new_nodes, node|
      yield(node)
      new_nodes + node.children
    end
  end
end

root = LicenseReader.new(File.open(ARGV[0])).read

puts "## Part 1"
sum_metadata = 0
bfs(root) { |node| sum_metadata += node.metadata.reduce(:+) }
puts "Answer = #{sum_metadata}"

puts "\n## Part 2"
puts "Answer = #{root.value}"
