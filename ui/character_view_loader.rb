# View character in centre pane
require_relative '../lib/util'
require_relative './markup'

class CharacterViewLoader
  include Markup

  def initialize builder, character
    @builder = builder
    @character = character
    set 'char-view name', color(character_color, character.name)
    ################
    set 'char-view hp', hp
    set 'char-view armour', armour
    set 'char-view speed', speed
    ################
    set 'char-view str', keyval('str', character.str)
    set 'char-view dex', keyval('dex', character.dex)
    set 'char-view con', keyval('con', character.con)
    set 'char-view int', keyval('int', character.int)
    set 'char-view wis', keyval('wis', character.wis)
    set 'char-view cha', keyval('cha', character.cha)
    ################
    set 'char-view type', type
    set 'char-view save-str', keyval('str', character.strength_save)
    set 'char-view save-dex', keyval('dex', character.dexterity_save)
    set 'char-view save-con', keyval('con', character.constitution_save)
    set 'char-view save-int', keyval('int', character.intelligence_save)
    set 'char-view save-wis', keyval('wis', character.wisdom_save)
    set 'char-view save-cha', keyval('cha', character.charisma_save)
  end

  private

  def armour
    ac = keyval('AC', @character.armor_class)
    desc = @character.armor_desc
    desc&.empty? ? ac : ac + " (#{desc})"
  end

  def hp
    hp = keyval('hp', bold(colored_hp))
    dice = @character.hit_dice
    dice&.empty? ? hp : hp + " (#{dice})"
  end

  def speed
    text = gray('speed')
    if walk = @character.speed['walk'].presence
      text += " walk #{walk}"
    end
    if swim = @character.speed['swim'].presence
      text += "swim #{swim}"
    end
    if fly = @character.speed['fly'].presence
      text += "fly #{fly}"
    end
    text
  end

  def type
    text = @character.type
    text += " #{@character.subtype}" if @character.subtype.presence
    text += " #{@character.group}" if @character.group.presence
    text += "; #{@character.alignment}"
  end

  # Gray key and as-is value
  def keyval key, val
    [gray(key), val].join(" ")
  end
  def is_player?
    !@character.is_a? Monster
  end
  def set id, markup
    obj = @builder.get_object(id)
    obj.set_markup(markup || '(ERRR)')
  end
end
