class Encounter
  attr_reader :npcs, :party

  def initialize party
    @party = party
    @npcs = Set.new
  end

  # DMG p.
  def xp_for_difficulty difficulty
    party_xp = @party.values.reduce(0) { |acc, pc|
      acc + pc.xp_threshold(difficulty)
    }

    case difficulty
    when EASY
    when MEDIUM
    when HARD
    when DEADLY
    else
      raise RuntimeError.new("Unsupported difficulty #{difficulty}")
    end
  end
  # Compute XP for difficulty for party
  # Compute CR for XP DMG p.275

  def self.random party, terrain, difficulty, opts={}
    cr = opts[:cr] || max_cr_for_party_and_difficulty
    cr /= multiplier(opts[:n]) if opts[:n]
    enc = new party
    # Find monster with CR no greater than cr
    monster_attrs = $monsters.sample terrain, opts[:strict], cr
    if opts[:n].nil? # Compute n based on cr & difficulty
      cr = monster_attrs['challenge_rating'].to_f

    end
    (1..n).each {|i| enc.npcs << Monster.new(monster_attrs) }
    enc
  end

  # Roll initiative
  def init name=nil, roll_value=nil
    @initiative ||= {}
    # Set pc roll
    if name
      pc = @party[name]
      return puts "No PC found for #{name}" if pc.nil?
      @initiative[pc] = roll_value
    end
    # Roll for npcs
    @npcs.each {|npc| @initiative[npc] = npc.roll_initiative }
  end

  # DMG p.82: Multiply the total XP of all the monsters in the encounter by
  # the value given in the Encounter Multipliers table.
  def multiplier number_of_monsters
    case number_of_monsters
    when 1; 1
    when 2; 1.5
    when 3..6; 2
    when 7..10; 2.5
    when 11..14; 3
    else; 4
    end
  end

  # Return the next guy in the initiative
  def next
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
