require './lib/monster_library'

class Encounter
  attr_reader :npcs, :party
  attr_reader :initiative_order

  def initialize party
    @party = party
    @npcs = []
    @initiative_cursor = 0
    @initiative_order = []
  end

  def cr
    return 0 if @npcs.empty?
    row = Table['encounter-multipliers.tsv'].find do |row|
      multiplier, range = row
      range_a, range_z = range.split('-')
      range_z ||= range_a
      @npcs.length >= range_a.to_i && @npcs.length <= range_z.to_i
    end
    multiplier = row[0].to_f
    multiplier * @npcs.sum {|npc| npc.cr }
  end

  # Compute CR for party (DMG p.275). Returns float
  def cr_for_party difficulty
    eval(self.class.crs_for_party(@party)[difficulty-1])
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

  # Return the next guy in the initiative
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

  # Returns Array of CR string values for party
  def self.crs_for_party party
    pcs = party.values
    difficulties = [EASY, MEDIUM, HARD, DEADLY]
    difficulties.map do |difficulty|
      # Compute party's XP threshold for given difficulty
      xp_threshold = pcs.sum {|pc| Table['xp-thresholds-by-character-level.tsv'][pc.level-1][difficulty-1].to_i }
      # Find nearest XP match in table, return CR
      cr, xp = Table['xp-by-cr.tsv'].min {|row_a, row_b|
        delta_a, delta_b = [row_a, row_b].map {|row|
          (row[1].to_i - xp_threshold).abs
        }
        delta_a <=> delta_b
      }
      cr
    end
  end

  # Compute XP for difficulty for party
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
