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
    super character.to_h
    @character = character
    set_name
    set_hp
    set_stats
    set_detail
    add_section 'Speed', @character.speed.to_h, delimiter: " "
    add_section 'Actions', @character.actions
    add_section 'Special abilities', @character.special_abilities
    add_section 'Legendary actions', @character.legendary_actions
    add_section 'Skills', @character.skills.to_h, delimiter: " "
    add_section 'Spells', @character.spells
  end


  def on_add_to_cast_activated widget
    CastUI.instance.add @character
  end

  def on_add_to_encounter_activated widget
    EncounterUI.instance.add @character
  end

  def on_copy_to_cast_activated widget
    CastUI.instance.copy @character
  end

  def on_copy_to_encounter_activated widget
    EncounterUI.instance.copy @character
  end

  private

  def saving_throws_markup
    [
      labeled('str', signed(@character.saves.str.to_i)),
      labeled('dex', signed(@character.saves.dex.to_i)),
      labeled('con', signed(@character.saves.con.to_i)),
      labeled('int', signed(@character.saves.int.to_i)),
      labeled('wis', signed(@character.saves.wis.to_i)),
      labeled('cha', signed(@character.saves.cha.to_i)),
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
      labeled('perception:', @character.passive_perception),
    ].compact.join("\n")
    obj('detail Label').set_markup(markup)
  end

  def set_hp
    markup = []
    markup << "HP #{colored_hp}" if @character.hp
    markup << "AC #{@character.ac}" if @character.ac
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
      <big><a href="#{@character.url}">#{name}</a></big>
      <small> #{small_txt}</small>
    EOF
    set 'name Label', markup.gsub(/\n/, '')
  end

  def set_stats
    labels = obj('stats FlowBox').children.map {|x| x.children.first }
    markup = ->(lbl) {
      key = lbl.downcase.to_sym
      val = @character.attrs[key]
      mod = ((val.to_i - 10) / 2).floor
      "%s\n%s (%s)" % [gray(lbl), val, mod]
    }
    labels.shift.set_markup markup.("STR")
    labels.shift.set_markup markup.("DEX")
    labels.shift.set_markup markup.("CON")
    labels.shift.set_markup markup.("INT")
    labels.shift.set_markup markup.("WIS")
    labels.shift.set_markup markup.("CHA")
  end

end
