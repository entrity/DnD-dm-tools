require 'forwardable'
require_relative './markup'

class Stats < Struct.new :str, :dex, :con, :int, :wis, :cha; end
class Speed < Struct.new :walk, :fly, :swim; end
class Action < Struct.new :name, :desc, :atk, :dmg_dice, :dmg_bonus
  def self.parse_array(arr)
    return if '' == arr
    arr.map { |a| Action.new *a.values_at(*%w[name desc attack_bonus damage_dice damage_bonus]) }
  end
end
class ActionArray < Array
  def initialize
  end
end
class Skills < Struct.new(*%i[acrobatics animal_handling arcana athletics deception history insight intimidation investigation medicine nature perception performance persuasion religion sleight_of_hand stealth survival]); end

class Character
  extend Forwardable
  include Markup

  attr_accessor :is_pc
  attr_accessor :name, :type, :subtype, :url,
    :hp, :proficiency, :max_hp, :temp_hp, :ac,
    :damage_vulnerabilities, :damage_resistances, :damage_immunities,
    :condition_immunities,
    :passive_perception
  attr_reader :challenge_rating, # You usually want `cr`
    :attrs, :saves, :speed, :languages, :skills,
    :pc_levels, :armor_desc, :spells
  attr_reader :senses, :actions, :reactions, :legendary_actions, :special_abilities

  def_delegators :@attrs, *Stats.members

  # def self.[] name_or_slug
  #   Character.new MonsterLibrary.instance[name_or_slug]
  # end

  def initialize
    @pc_levels = []
  end

  def <=> other
    (name.presence||klass).downcase <=> (other.name.presence||other.klass).downcase
  end

  def copy_from other
    @senses = senses.dup
    @actions = actions.dup
    @reactions = reactions.dup
    @legendary_actions = legendary_actions.dup
    @special_abilities = special_abilities.dup
    @pc_levels = pc_levels.dup
    @attrs = attrs.dup
    @saves = saves.dup
    @speed = speed.dup
    @languages = languages.dup
    @skills = skills.dup
  end

  def cr; eval "#{challenge_rating||0}.0"; end

  def dup
    super.tap { |d| d.copy_from self }
  end

  def inspect
    to_s
  end

  def klass
    pc_levels.first || @name
  end

  def label
    if name != klass
      "%s (%s)" % [name, klass]
    else
      name
    end
  end

  def level; raise NotImplementedError; end

  def level= val; raise NotImplementedError; end

  def load_open5e dict
    dict = dict.to_h.transform_keys(&:to_s)
    csv = -> (key) { dict.fetch(key).split(/,\s*/) }
    @charname = nil
    @klass_levels = {}
    @hp = dict.fetch('hit_points').to_i
    @ac = dict.fetch('armor_class').to_i
    # Struct values
    @attrs = Stats.new *dict.values_at(*%w[strength dexterity constitution intelligence wisdom charisma])
    @saves = Stats.new *dict.values_at(*%w[strength_save dexterity_save constitution_save intelligence_save wisdom_save charisma_save])
    @speed = Speed.new *dict.fetch('speed', {}).values_at(*%w[walk fly swim])
    # CSV's
    @damage_vulnerabilities = csv.('damage_immunities')
    @damage_resistances = csv.('damage_resistances')
    @damage_immunities = csv.('damage_immunities')
    @condition_immunities = csv.('condition_immunities')
    @languages = csv.('languages')
    @senses = csv.('senses')
    # Plain values
    @name, @armour, @spells, @img_url, @challenge_rating, @hit_dice, @alignment, @name, @size, @type, @subtype, @passive_perception, @legendary_desc = dict.values_at(*%w[
      name armor_desc spell_list img_main challenge_rating hit_dice alignment name size type subtype perception legendary_desc
    ])
    # Other
    @actions = Action.parse_array(dict.fetch('actions'))
    @reactions = Action.parse_array(dict.fetch('reactions'))
    @legendary_actions = Action.parse_array(dict.fetch('legendary_actions'))
    @special_abilities = Action.parse_array(dict.fetch('special_abilities'))
    @proficiency = nil
    @skills = Skills.new dict.values_at(*%w[acrobatics animal_handling arcana athletics deception history insight intimidation investigation medicine nature perception performance persuasion religion sleight_of_hand stealth survival])
    dict.fetch('skills').each { |k,v| @skills[k] = v }
    @url = "https://open5e.com/monsters/#{ dict['slug'] }"
    self
  end

  # Compute modifier for an attribute score
  def mod attribute_score
    ((attribute_score - 10) / 2).floor
  end

  def roll_initiative
    Roll.new("d20 + #{mod(dex)}").value
  end

  def to_h
    {}
  end

  def to_s
    "<#{self.name}:#{object_id} cr #{challenge_rating} hp #{hp}\>"
  end

  private

  def color_hp
    if hp.nil?
      ''
    elsif hp <= 0
      red(bg_black(hp))
    elsif hp < 5
      red(hp)
    else
      cyan(hp)
    end
  end
end
