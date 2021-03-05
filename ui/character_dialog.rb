require 'gtk3'
require 'singleton'
require_relative '../lib/characters'
require_relative './character_view_loader'

# Include this in main
class CharacterDialog < Gtk::Dialog
  include Singleton

  @@builder = Gtk::Builder.new(:file => File.join(XML_DIR, "character_dialog.ui"))
  @@player_klass_autocomplete_model = Gtk::ListStore.new(String)
  @@has_run = false

  def initialize *args, **kwargs
    puts "initializer"
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
          DialogLoader.new(self, tmp_char).load
        end
        nil
      end
    end
    # Add buttons & button-behaviour
    add_buttons [Gtk::Stock::OK, Gtk::ResponseType::ACCEPT], [Gtk::Stock::CANCEL, Gtk::ResponseType::CANCEL]
    signal_connect('response') { |dialog, response|
      if Gtk::ResponseType::ACCEPT == response
        DialogLoader.new(self, @character).dump
        CastUI.instance.reload true
      end
      dialog.hide
    }
  end

  def get(id); obj(id).text; end

  def obj id
    @obj ||= {}
    @obj[id] ||= @@builder.get_object(id)
  end

  def open character=nil
    @character = character.is_a?(Character) ? character : Character.new
    DialogLoader.new(self, @character).load
    @@has_run ? show : run
    @@has_run = true
  end

  def set id, value
    obj(id).set_text(value.to_s)
  end

  class DialogLoader
    def initialize dialog, character
      @dialog = dialog
      @char = character
      raise ArgumentError.new("@char is #{@char.class}") unless @char.is_a?(Character)
      raise ArgumentError.new("@dialog is #{@dialog.class}") unless @dialog.is_a?(Gtk::Dialog)
    end

    def dump
      @char.klass    = @dialog.get('character class')
      @char.is_pc    = @dialog.obj('char dialog pc Radio').active?
      @char.name     = @dialog.get('name')
      @char.type     = @dialog.get('type')
      @char.subtype  = @dialog.get('subtype')
      @char.group    = @dialog.get('group')
      @char.max_hp   = @dialog.get('maxhp').to_i
      @char.hp       = @dialog.get('hp').to_i
      @char.hit_dice = @dialog.get('hit dice')
      @char.str      = @dialog.get('str').to_i
      @char.dex      = @dialog.get('dex').to_i
      @char.con      = @dialog.get('con').to_i
      @char.int      = @dialog.get('int').to_i
      @char.wis      = @dialog.get('wis').to_i
      @char.cha      = @dialog.get('cha').to_i
      CharacterViewLoader.content_set @char
    end

    def load char=nil
      char ||= @char
      @dialog.set 'name', char.name
      @dialog.set 'character class', char.klass
      @dialog.set 'type', char.type
      @dialog.set 'subtype', char.subtype
      @dialog.set 'group', char.group
      @dialog.set 'maxhp', char.max_hp
      @dialog.set 'hp', char.hp
      @dialog.set 'hit dice', char.hit_dice
      @dialog.set 'str', char.str
      @dialog.set 'dex', char.dex
      @dialog.set 'con', char.con
      @dialog.set 'int', char.int
      @dialog.set 'wis', char.wis
      @dialog.set 'cha', char.cha
    end
  end
end

Thread.new do
  CharacterDialog.instance
end

module CharacterDialogFunctions
  def character_dialog_open_new *args
    CharacterDialog.instance.open nil
  end
end
