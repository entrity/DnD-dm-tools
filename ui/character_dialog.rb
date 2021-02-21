require 'gtk3'
require 'singleton'
require_relative '../lib/characters'
require_relative './character_view_loader'

# Include this in main
class CharacterDialog < Gtk::Dialog
  include Singleton

  @@builder = Gtk::Builder.new(:file => File.join(XML_DIR, "character_dialog.ui"))
  @@player_klass_autocomplete_model = Gtk::ListStore.new(String)

  def initialize *args, **kwargs
    super
    # Add content
    wrapper = @@builder.get_object('wrapper')
    children.first.add wrapper
    # Add autocomplete
    MyAutocomplete.add @@builder.get_object('character class') do |model, completion|
      # Set model
      strings = MonsterLibrary.instance.list.map {|mon| mon['name'] } + Character::PLAYER_CLASSES
      strings.sort.each {|str| @@player_klass_autocomplete_model.append.set_value 0, str }
      completion.set_model @@player_klass_autocomplete_model
      # Set match function
      completion.set_match_func do |completion, entry_value, list_obj|
        list_obj.get_value(0).downcase =~ Regexp.new(completion.entry.text.downcase)
      end
      # Set match-selected callback
      completion.signal_connect("match-selected") do |completion, list_store, tree_iter|
        text = list_store.get_value(tree_iter, 0)
        if attrs = MonsterLibrary.instance[text].presence
          tmp_char = Character.new attrs.merge @character.attrs
          DialogLoader.new(@@builder, tmp_char).load
        end
        nil
      end
    end
    # Add buttons & button-behaviour
    add_buttons [Gtk::Stock::OK, Gtk::ResponseType::ACCEPT], [Gtk::Stock::CANCEL, Gtk::ResponseType::CANCEL]
    signal_connect('response') { |dialog, response|
      hide
      DialogLoader.new(@@builder, @character).dump if Gtk::ResponseType::ACCEPT == response
    }
  end

  def open character=nil
    @character = character.is_a?(Character) ? character : Character.new
    DialogLoader.new(@@builder, @character).load
    show_all
  end

  class DialogLoader
    def initialize builder, character
      @builder = builder
      @char = character
      raise ArgumentError.new("@char is #{@char.class}") unless @char.is_a?(Character)
      raise ArgumentError.new("@builder is #{@builder.class}") unless @builder.is_a?(Gtk::Builder)
    end

    def dump
      @char.klass = get('character class')
      @char.is_pc = get_obj('char dialog pc Radio').active?
      @char.name = get('name')
      @char.type = get('type')
      @char.subtype = get('subtype')
      @char.group = get('group')
      @char.max_hp = get('maxhp').to_i
      @char.hp = get('hp').to_i
      @char.hit_dice = get('hit dice')
      @char.str = get('str').to_i
      @char.dex = get('dex').to_i
      @char.con = get('con').to_i
      @char.int = get('int').to_i
      @char.wis = get('wis').to_i
      @char.cha = get('cha').to_i
      CharacterViewLoader.content_set $main_builder, @char      
    end

    def load char=nil
      char ||= @char
      set 'name', char.name
      set 'character class', char.klass
      set 'type', char.type
      set 'subtype', char.subtype
      set 'group', char.group
      set 'maxhp', char.max_hp
      set 'hp', char.hp
      set 'hit dice', char.hit_dice
      set 'str', char.str
      set 'dex', char.dex
      set 'con', char.con
      set 'int', char.int
      set 'wis', char.wis
      set 'cha', char.cha
    end

    private

    def get(id); get_obj(id).text; end

    def get_obj(id); @builder.get_object(id); end

    def set id, value
      @builder.get_object(id).set_text(value.to_s) unless value.nil?
    end
  end
end

Thread.new do
  CharacterDialog.instance
end

module CharacterDialogFunctions
  def character_dialog_open *args
    CharacterDialog.instance.open
  end
end
