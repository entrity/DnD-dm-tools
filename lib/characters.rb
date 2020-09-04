class Character
  def melee
  end

  def ranged
  end
end

class Pc < Struct.new()
  include Character
end

class Npc < Struct.new()
  include Character
end

class Foe < Npc
end

class Monster < Foe
  def initialize attrs
  end
end

class Party
end
