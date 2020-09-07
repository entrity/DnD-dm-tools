require './lib/ansi'

class Character
  def initialize attrs={}
    @attrs = attrs
  end

  def cr
    challenge_rating.to_f
  end

  def inspect
    "<#{self.class.name}:#{object_id} name \"#{name}\" cr #{challenge_rating}\>"
  end

  def mod attribute_score
    ((attribute_score - 10) / 2).floor
  end

  def roll_initiative
    Roll.new("d20 + #{mod(dex)}").value
  end

  def to_s
    out = [h1(name), Ansi.faint('cr'), challenge_rating, Ansi.faint('hp'), color_hp, Ansi.faint('ac'), ac, Ansi.faint('spd'), speed].join(' ') + "\n"
    out += %i[str dex con int wis cha].map {|s| [Ansi.faint(s), send(s)]}.join(" ")
    _actions = actions.map {|a| [Ansi.underline(a['name']), Ansi.faint(a['desc'])].join(' ') }.join("\n")
    _special_abilities = special_abilities.map {|a| [Ansi.underline(a['name']), Ansi.faint(a['desc'])].join(' ') }.join("\n")
    out += "\n\n#{Ansi.yellow 'Actions'}\n#{_actions}" if _actions
    out += "\n\n#{Ansi.yellow 'Special abilities'}\n#{_special_abilities}" if _special_abilities
  end

  def self.attr attr_name, *aliases
    aliases.unshift(attr_name).each do |method_name|
      define_method method_name do
        @attrs[attr_name.to_s]
      end

      define_method "#{method_name}=" do |value|
        @attrs[attr_name.to_s] = value
      end
    end
  end

  private

  def color_hp
    if hp <= 0
      [Ansi.fmt(Ansi::RED, Ansi::BG_BLACK), hp, Ansi.fmt(Ansi::FG_RESET, Ansi::BG_RESET)].join
    elsif hp < 5
      Ansi.red hp
    else
      [Ansi.fmt(Ansi::CYAN), hp, Ansi.fmt(Ansi::FG_RESET)].join
    end
  end

  def h1 text
    [Ansi.fmt(Ansi::BOLD, Ansi::YELLOW), text, Ansi.fmt(Ansi::BOLD_OFF, Ansi::FG_RESET)].join
  end

  attr :slug # "bandit-captain",
  attr :name # "Bandit Captain",
  attr :size # "Medium",
  attr :type # "humanoid",
  attr :subtype # "any race",
  attr :group # nil,
  attr :alignment # "any non-lawful alignment",
  attr :armor_class, :ac # 15,
  attr :armor_desc # "studded leather",
  attr :hit_points, :hp # 65,
  attr :hit_dice # "10d8",
  attr :speed # {"walk # 30},
  attr :strength, :str # 15,
  attr :dexterity, :dex # 16,
  attr :constitution, :con # 14,
  attr :intelligence, :int # 14,
  attr :wisdom, :wis # 11,
  attr :charisma, :cha # 14,
  attr :strength_save # 4,
  attr :dexterity_save # 5,
  attr :constitution_save # nil,
  attr :intelligence_save # nil,
  attr :wisdom_save # 2,
  attr :charisma_save # nil,
  attr :perception # nil,
  attr :skills # {"athletics # 4, "deception # 4},
  attr :damage_vulnerabilities # "",
  attr :damage_resistances # "",
  attr :damage_immunities # "",
  attr :condition_immunities # "",
  attr :senses # "passive Perception 10",
  attr :languages # "any two languages",
  attr :challenge_rating # "2",
  attr :actions
  attr :special_abilities
end

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

class Foe < Npc
end

class Monster < Foe
end

class Party < Hash
end
