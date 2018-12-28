Unit = Struct.new(:id, :type, :hp, :power, :x, :y) do
  def alive?
    hp > 0
  end

  def pos
    [x, y]
  end

  def to_s
    type
  end
end
