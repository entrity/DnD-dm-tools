# View character in centre pane
require_relative '../lib/util'
require_relative './markup'

class CharacterViewLoader
  include Markup

  # Set Character view in the 'content ViewPort'
  def self.content_set builder, character
    @@character = character
    @@wrapper ||= builder.get_object 'content Box'
    @@sub_builder_file ||= "#{File.expand_path(File.dirname(__FILE__))}/character_view.ui"
    @@sub_builder ||= Gtk::Builder.new(:file => @@sub_builder_file)
    @@sub_builder.connect_signals {|handler| self.method(handler) }
    @@widget ||= @@sub_builder.get_object 'character view'
    @@wrapper.children.each {|c| @@wrapper.remove_child c }
    @@wrapper.set_child @@widget
    self.new @@sub_builder, character
  end

  def self.open_character_dialog_from_cvl
    puts "open editor called"
    open_character_dialog @@character
  end


  private

  def initialize builder, character
    @builder = builder
    @character = character
    set 'char-view name', color(character_color, character.name)
    ################
    set 'char-view hp', hp
    set 'char-view level', level
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
    set 'char-view senses', keyval('senses', character.senses, autohide: true), autohide: true
    set 'char-view languages', keyval('languages', character.languages, autohide: true), autohide: true
    set 'char-view vulnerabilities', keyval('vulnerabilities', character.damage_vulnerabilities, autohide: true), autohide: true
    set 'char-view resistances', keyval('resistances', character.damage_resistances, autohide: true), autohide: true
    set 'char-view immunities', keyval('immunities', character.damage_immunities, autohide: true), autohide: true
    ################
    set 'char-view skills', hash_info(character.skills)
    # langs, immunities, senses
    set 'char-view spells', array_info(character.spell_list)
    set 'char-view special-abilities', array_info(character.special_abilities)
    set 'char-view actions', array_info(character.actions)
    set 'char-view reactions', array_info(character.reactions)
    set 'char-view legendary', legendary
    ################
    ################
    ################
  end

  private

  def armour
    ac = keyval('AC', @character.armor_class)
    desc = @character.armor_desc
    desc&.empty? ? ac : ac + " (#{desc})"
  end

  def array_info data, default='(none)'
    if data.is_a? Array
      data.map {|act|
        [bold(act['name']), act['desc']].join(" ")
      }.join("\n").presence || default
    else
      data || default
    end
  end

  def hash_info data, default='(none)'
    data.map { |k,v|
      [bold(k), v].join(" ")
    }.join("\n").presence || default
  end

  def hp
    hp = keyval('hp', bold(colored_hp))
    dice = @character.hit_dice
    dice&.empty? ? hp : hp + " (#{dice})"
  end

  def legendary default='(none)'
    [@character.legendary_desc, array_info(@character.legendary_actions)].compact.join("\n").presence || default
  end

  def level
    if @character.is_a?(Monster)
      keyval "CR", @character.challenge_rating
    else
      keyval "LVL", @character.level
    end
  end

  def speed
    text = gray('speed')
    if walk = @character.speed['walk'].presence
      text += " walk #{walk}"
    end
    if swim = @character.speed['swim'].presence
      text += " swim #{swim}"
    end
    if fly = @character.speed['fly'].presence
      text += " fly #{fly}"
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
  def keyval key, val, opts={}
    return if opts[:autohide] && !val.presence
    [gray(key), val].join(" ")
  end
  def is_player?
    !@character.is_a? Monster
  end
  def set id, markup, opts={}
    obj = @builder.get_object(id)
    obj.set_visible(!!markup.presence) if opts[:autohide]
    obj.set_markup(markup || '(ERRR)')
  end
end
