require_relative '../character.rb'

# A PC has player-class levels
class Pc < Character
  def initialize name, lvls
    @is_pc = true # is_pc means it's controlled by the party, not that it has player class levels
    super()
    @name = name
    if lvls.is_a? Integer
      @pc_levels = ['unspecified'] * lvls
    else
      @pc_levels += lvls
    end
  end

  def klass=(value)
    @pc_levels[0] = value
  end

  def level
    @pc_levels.length
  end
  alias_method :challenge_rating, :level

  def level= int
    while @pc_levels.length > int
      @pc_levels.pop
    end
    while @pc_levels.length < int
      @pc_levels.push @pc_levels.last
    end
  end

  def levelup pc_klass_name
    @pc_levels.push pc_klass_name
  end

  def xp_threshold difficulty
    table = Table['xp-thresholds-by-character-level.tsv']
    table[level - 1][difficulty - 1].to_i
  end
end
