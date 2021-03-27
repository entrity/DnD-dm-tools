require 'gtk3'
require 'forwardable'
require_relative '../lib/constants'
require_relative 'builder_view'
require_relative 'markup'
require_relative 'secondary_window'

class CharacterView < BuilderView
  extend Forwardable
  include Markup

  BUILDER_FILE = File.join(XML_DIR, 'monster_window.ui')

  def_delegators :@character, :slug, :name, :level, :klass

  def initialize character
    super character.attrs
    @character = character
    set_name
    set_hp
    set_stats
    set_detail
    add_section 'Speed', @character.speed, delimiter: " "
    add_section 'Actions', @character.actions
    add_section 'Special abilities', @character.special_abilities
    add_section 'Legendary actions', @character.legendary_actions
    add_section 'Skills', @character.skills, delimiter: " "
    add_section 'Spells', @character.spell_list
  end


  def on_add_to_cast_activated widget
    CastUI.instance.add @character
  end

  def on_add_to_encounter_activated widget
    EncounterUI.instance.add @character
  end

  def on_copy_to_cast_activated widget
    CastUI.instance.add @character.dup
  end

  def on_copy_to_encounter_activated widget
    EncounterUI.instance.add @character.dup
  end

  private

  def saving_throws_markup
    [
      labeled('str', signed(@character.strength_save.to_i)),
      labeled('dex', signed(@character.dexterity_save.to_i)),
      labeled('con', signed(@character.constitution_save.to_i)),
      labeled('int', signed(@character.intelligence_save.to_i)),
      labeled('wis', signed(@character.wisdom_save.to_i)),
      labeled('cha', signed(@character.charisma_save.to_i)),
    ].join(' ')
  end

  def set_detail
    markup = [
      labeled('Saving Throws:', saving_throws_markup),
      labeled('Damage vulnerabilities:', @character.damage_vulnerabilities),
      labeled('Damage resistances:', @character.damage_resistances),
      labeled('Damage immunities:', @character.damage_immunities),
      labeled('Condition immunities:', @character.condition_immunities),
      labeled('reactions:', @character.reactions),
      labeled('senses:', @character.senses),
      labeled('languages:', @character.languages),
      labeled('condition_immunities:', @character.condition_immunities),
      labeled('perception:', @character.perception),
    ].compact.join("\n")
    obj('detail Label').set_markup(markup)
  end

  def set_hp
    markup = []
    markup << "HP #{colored_hp}" if @character.hp
    markup << "AC #{@character.armor_class}" if @character.armor_class
    markup = markup.compact.join(' / ')
    set 'hp Label', markup unless markup.empty?
  end

  def set_name
    if @character.is_a?(Monster)
      lvl_txt = " (cr %s | xp %d)" % [level, Encounter.xp_for_cr(@character.level)]
    elsif level
      lvl_txt = " (lvl %d)" % [level]
    end
    klass_txt = klass if klass != name
    small_txt = [lvl_txt, klass_txt].compact.join(" ")
    markup = <<~EOF
      <big><a href="https://open5e.com/monsters/#{@dict['slug']}">#{name}</a></big>
      <small> #{small_txt}</small>
    EOF
    set 'name Label', markup.gsub(/\n/, '')
  end

  def set_stats
    labels = obj('stats FlowBox').children.map {|x| x.children.first }
    markup = ->(lbl, key) {
      val = @dict[key]
      mod = ((val.to_i - 10) / 2).floor
      "%s\n%s (%s)" % [gray(lbl), val, mod]
    }
    labels.shift.set_markup markup.call("STR", 'strength')
    labels.shift.set_markup markup.call("DEX", 'dexterity')
    labels.shift.set_markup markup.call("CON", 'constitution')
    labels.shift.set_markup markup.call("INT", 'strength')
    labels.shift.set_markup markup.call("WIS", 'wisdom')
    labels.shift.set_markup markup.call("CHA", 'charisma')
  end

end
