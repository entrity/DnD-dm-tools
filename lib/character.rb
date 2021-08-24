require 'forwardable'
require_relative 'markup'
require_relative 'monster_library'

class Character
  extend Forwardable
  include Markup

  attr_accessor :is_pc
  attr_reader :attrs
  attr_writer :klass

  def_delegators :@attrs, :[]

  def self.[] name_or_slug
    Character.new MonsterLibrary.instance[name_or_slug]
  end

  def initialize attrs={}
    attrs = MonsterLibrary.instance[attrs] if attrs.is_a? String
    @attrs = attrs.dup
    self.name ||= @klass
  end

  def <=> other
    (name.presence||klass) <=> (other.name.presence||other.klass)
  end

  def cr; eval "#{challenge_rating}.0"; end

  def dup
    self.class.new @attrs.dup
  end

  def inspect
    %Q{<#{klass}:#{object_id} #{name} hp="#{hp}" lv="#{level}">}
  end

  def klass; @klass || name; end

  def label
    if name != klass
      "%s (%s)" % [name, klass]
    else
      name
    end
  end

  def level; challenge_rating; end

  def level= val; self.challenge_rating = val; end

  # Compute modifier for an attribute score
  def mod attribute_score
    ((attribute_score - 10) / 2).floor
  end

  def roll_initiative
    Roll.new("d20 + #{mod(dex)}").value
  end

  def to_s
    "<#{self.class.name}:#{object_id} name \"#{name}\" cr #{challenge_rating} hp #{hp}\>"
  end

  def self.attr attr_name, *aliases
    aliases.unshift(attr_name).each do |method_name|
      define_method method_name do
        instance_variable_get(:@attrs)&.[] attr_name.to_s
      end

      define_method "#{method_name}=" do |value|
        instance_variable_get(:@attrs)&.[]= attr_name.to_s, value
      end
    end
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
  attr :max_hp
  attr :hit_dice # "10d8",
  attr :speed # {"walk # 30},
  attr :spell_list
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
  attr :legendary_desc
  attr :legendary_actions
  attr :reactions # "passive Perception 10",
  attr :senses # "passive Perception 10",
  attr :languages # "any two languages",
  attr :challenge_rating # "2",
  attr :actions
  attr :special_abilities
end
