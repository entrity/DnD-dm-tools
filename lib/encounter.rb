class Encounter
  def initialize party
    @party = party
    @npcs = Set.new
  end

  def self.random party, terrain, difficulty, n=nil
    monster_klass = 
    enc = new party
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

  def multipliers number_of_monsters
    case number_of_monsters
    when 1; 1
    when 2; 1.5
    when 3..6; 2
    when 7..10; 2.5
    when 11..14; 3
    else; 4
    end
  end

  def next

  end

  # Difficulty
  EASY = :easy
  MEDIUM = :medium
  HARD = :hard
  DEADLY = :deadly
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
