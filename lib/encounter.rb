require './lib/monster_library'
require 'forwardable'

class Encounter
  extend Forwardable
  attr_reader :npcs, :party
  attr_reader :initiative_order

  def initialize party
    @party = party
    @npcs = []
    @initiative_cursor = 0
    @initiative_order = []
  end

  # Add NPC based on slug
  def add slug
    if foe = Monster[slug]
      @npcs << foe
    else
      raise "No foe found for slug #{slug}"
    end
  end

  # Compute CR based on the XP for this encounter
  def cr
    cr_for_xp(xp)
  end

  # Compute CR for party+difficulty (DMG p.275). Returns float
  def cr_for_party difficulty
    self.class.crs_for_party(@party)[difficulty-1]
  end

  # Roll initiative
  def init name_or_pc=nil, roll_value=nil
    @initiative ||= {}
    # Set pc roll
    if x = name_or_pc
      pc = x.is_a?(String) ? @party[x] : x
      return puts "No PC found for #{name}" if pc.nil?
      @initiative[pc] = roll_value
    end
    # Roll for npcs
    @npcs.each {|npc| @initiative[npc] = npc.roll_initiative }
    @initiative_order = @initiative.to_a.sort {|x| x[1]}.map {|x| x[0]}
  end

  # Return the next character in the initiative order, update the cursor.
  def pop
    character = @initiative_order[@initiative_cursor]
    @initiative_cursor += 1
    @initiative_cursor = 0 if @initiative_cursor >= @initiative_order.length
    character
  end

  def hoard
    Treasure.hoard cr
  end

  def treasure
    Treasure.individual cr
  end

  # XP earned from encounter
  def xp
    xp_sum = @npcs.sum {|c| xp_for_cr[c.cr] }
    xp_sum * xp_multiplier(@npcs&.length.to_i)
  end

  # Returns Array of CR string values for party for all difficulties
  def self.crs_for_party party
    pcs = party.values
    difficulties = [EASY, MEDIUM, HARD, DEADLY]
    difficulties.map do |difficulty|
      # Compute party's XP threshold for given difficulty
      xp_threshold = pcs.sum {|pc| Table['xp-thresholds-by-character-level.tsv'][pc.level-1][difficulty-1].to_i }
      cr_for_xp(xp_threshold)
    end
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
    (1..n).each {|i| enc.npcs << Monster.new(monster_attrs) }
    enc
  end

  # Return Hash of {XP => CR}
  def self.xp_for_cr
    @@xp_by_cr ||= Table['xp-by-cr.tsv'].map {|k,v| [eval("#{k}.0"), v.to_i] }.to_h
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
  MOUNTAIN = "Mountain"
  UNDERDARK = "Underdark"
  ARCTIC = "Arctic"
  FOREST = "Forest"
  JUNGLE = "Jungle"
  GRASSLAND = "Grassland"
  HILL = "Hill"
  URBAN = "Urban"
  DESERT = "Desert"
  UNDERWATER = "Underwater"
  SWAMP = "Swamp"
  COASTAL = "Coastal"
end
