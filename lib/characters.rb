require_relative './ansi'
require_relative './table'
require_relative './character'

class PlayerClassName < String; end


class Pc < Character
  attr_accessor :name, :level

  def initialize *args, **attrs
    super attrs
    @name, @level = args
  end

  def challenge_rating
    @level
  end

  def xp_threshold difficulty
    table = Table['xp-thresholds-by-character-level.tsv']
    table[@level - 1][difficulty - 1].to_i
  end
end

class Npc < Character
end

# See MonsterLibrary class for how/where monster classes are loaded
class Monster < Npc
end

class Party < Hash
end
