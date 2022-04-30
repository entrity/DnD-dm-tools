require 'forwardable'
require 'set'
require_relative 'table'

class Encounter
  extend Forwardable
  include Enumerable

  attr_reader :cast, :initiative_order
  def_delegators :cast, :<<, :delete, :each, :includes?

  def initialize cast=nil
    @cast = SortedSet.new cast
    @initiative_order = {}
  end

  # Compute CR based on the XP for this encounter
  def cr; cr_for_xp(xp); end

  # Compute CR for party+difficulty (DMG p.275). Returns float
  def cr_for_party difficulty
    crs_for_party[difficulty-1]
  end

  # Returns Array of CR string values for party for all difficulties
  def crs_for_party
    difficulties = [EASY, MEDIUM, HARD, DEADLY]
    difficulties.map do |difficulty|
      # Compute party's XP threshold for given difficulty
      xp_threshold = get_pcs.sum {|pc| Table['xp-thresholds-by-character-level.tsv'][pc.level.to_i-1][difficulty-1].to_i }
      self.class.cr_for_xp(xp_threshold)
    end
  end

  def difficulty
    rounded_cr = cr.round
    easy, med, hard, deadly = crs_for_party
    if rounded_cr < med
      EASY
    elsif rounded_cr == med
      MEDIUM
    elsif rounded_cr == hard
      HARD
    elsif rounded_cr > hard
      DEADLY
    else
      raise ArgumentError.new("Unrecognized cr: #{rounded_cr} : #{crs_for_party.inspect}")
    end
  end

  def get_pcs
    cast.select {|c| c.is_pc }
  end

  def get_npcs
    cast.select {|c| !c.is_pc }
  end

  def initiative_for character; @initiative_order[character].to_i; end

  def hoard
    Treasure.hoard cr
  end

  def remove character; @cast.delete character; end

  def roll_npcs_initiative
    cast.each do |char|
      next if char.is_pc
      value = Roll.new("d20 + #{char.mod char.dex}").value
      set_initiative(char, value)
    end
  end

  def set_initiative character, roll_value; @initiative_order[character] = roll_value; end

  def treasure
    Treasure.individual cr
  end

  # XP earned from encounter
  def xp
    xp_sum = get_npcs.sum {|c| xp_for_cr[c.cr] }
    xp_sum * xp_multiplier(get_npcs&.length.to_i)
  rescue => ex
    require 'pry'; binding.pry
  end

  # Find nearest XP match in table, return corresponding CR
  def self.cr_for_xp xp_target
    cr, xp = xp_for_cr.min { |row_a, row_b|
      deltas = [row_a, row_b].map {|_, row_xp| (row_xp.to_i - xp_target).abs }
      deltas[0] <=> deltas[1]
    }
    cr
  end
  def_delegator self, :cr_for_xp

  # Create a random encounter
  def self.random party, difficulty, terrain, opts={}
    enc = new party
    cr = opts[:cr] || enc.cr_for_party(difficulty)
    cr /= multiplier(opts[:n]) if opts[:n]
    # Find monster with CR no greater than cr
    monster_attrs = MonsterLibrary.sample terrain: terrain, cr: cr, strict: opts[:strict]
    selected_monster_cr = MonsterLibrary.cr(monster_attrs)
    if n = opts[:n]
      # noop
    elsif 0 == selected_monster_cr
      n = 1 + rand(10)
    else # Compute n based on cr & difficulty
      mon_multiplier = cr / selected_monster_cr
      # Find the number of monsters to yield a CR closest to the CR from the table
      n_monsters_range, _ = Table['encounter-multipliers.tsv'].min do |row_a, row_b|
        delta_a, delta_b = [row_a, row_b].map {|row| (row[1].to_f - mon_multiplier).abs }
        delta_a <=> delta_b
      end
      a, z = n_monsters_range.split(/-/).map(&:to_i)
      z ||= a
      n = (a..z).to_a.sample
    end
    (1..n).each {|i| enc.cast << Monster.new.load_open5e(monster_attrs) }
    enc
  end

  # Return Hash of {XP => CR}
  def self.xp_for_cr cr=nil
    @@xp_by_cr ||= Table['xp-by-cr.tsv'].map {|k,v| [eval("#{k}.0"), v.to_i] }.to_h
    cr ? @@xp_by_cr[cr.to_f] : @@xp_by_cr
  end
  def_delegator self, :xp_for_cr

  # Look up XP multiplier for encounter with multiple foes
  def self.xp_multiplier n_foes
    range_str, mult_str = Table['encounter-multipliers.tsv'].find do |row|
      range, multiplier = row
      range_a, range_z = range.split('-')
      range_z ||= range_a
      n_foes >= range_a.to_i && n_foes <= range_z.to_i
    end
    mult_str.to_f
  end
  def_delegator self, :xp_multiplier

  # Difficulty
  EASY = 1
  MEDIUM = 2
  HARD = 3
  DEADLY = 4
  # Terrain
  ARCTIC = "Arctic"
  COASTAL = "Coastal"
  DESERT = "Desert"
  FOREST = "Forest"
  GRASSLAND = "Grassland"
  HILL = "Hill"
  JUNGLE = "Jungle"
  MOUNTAIN = "Mountain"
  SWAMP = "Swamp"
  UNDERDARK = "Underdark"
  UNDERWATER = "Underwater"
  URBAN = "Urban"
end
if __FILE__ == $0
  # Print CR table for party of given levels
  ally_lvls = $ARGV.map(&:to_i)
  p ally_lvls
  xp_sums_by_difficulty = [0,0,0,0]
  xp_sums_by_difficulty.each_with_index do |_, difficulty_idx|
    ally_lvls.each do |lvl|
      xp = Table['xp-thresholds-by-character-level.tsv'][lvl - 1][difficulty_idx].to_i
      xp_sums_by_difficulty[difficulty_idx] += xp
    end
  end
  p xp_sums_by_difficulty
  crs_by_difficulty = xp_sums_by_difficulty.map { |xp| Encounter.cr_for_xp xp }
  p crs_by_difficulty
end
