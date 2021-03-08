require 'gtk3'
require_relative '../lib/characters'
require_relative '../lib/character/player_class'
require_relative '../lib/character/player_class_library'
require_relative '../lib/monster_library'
require_relative '../lib/spell_library'
require_relative './monster_window'
require_relative './player_class_window'
require_relative './spell_window'

class SearchUI
  attr_reader :entry

  def initialize(builder)
    @builder = builder
    @entry = builder.get_object 'search Entry'
    Thread.new { load_autocomplete }
  end

  private

  def load_autocomplete
    autocomplete_model = Gtk::ListStore.new String, SearchUI::SearchUIRow
    items = []
    items += Character::PlayerClassLibrary.instance.list.map do |s|
      SearchUI::PlayerClassRow.new(s)
    end
    items += MonsterLibrary.instance.list.map do |m|
      SearchUI::MonsterRow.new(m)
    end
    items += SpellLibrary.instance.list.map do |s|
      SearchUI::SpellRow.new(s)
    end
    items.sort! {|a,b| a.name <=> b.name }
    items.each do |obj|
      x = autocomplete_model.append
      x.set_value 0, "#{obj.class::EMOJI} #{obj.name}"
      x.set_value 1, obj
    end
    completion = Gtk::EntryCompletion.new
    completion.set_minimum_key_length 0
    completion.set_text_column 0
    completion.set_inline_completion true
    completion.set_model autocomplete_model
    completion.set_match_func { |*args| match_func *args }
    completion.signal_connect("match-selected") do |completion, treemodel, treeiter|
      obj = treemodel.get_value(treeiter, 1)
      obj.activate
      @entry.set_text ''
    end
    @entry.set_completion completion
  end

  def match_func(entry_completion, entry_value, list_obj)
    entry_text = entry_completion.entry.text
    obj_text = list_obj.get_value(0)
    return obj_text.downcase.include?(entry_text.downcase)
  end
end

class SearchUI::SearchUIRow
  attr_reader :name
  attr_reader :sort_key

  def show
    raise NotImplementedError.new
  end
end

class SearchUI::MonsterRow < SearchUI::SearchUIRow
  def initialize monster
    super()
    @monster = monster
    @name = monster['name']
  end

  COLOR = '#a8a866'
  EMOJI = "\u{1F47B}"

  def activate
    MonsterWindow.new Monster.new @monster
  end
end

class SearchUI::PlayerClassRow < SearchUI::SearchUIRow
  COLOR = '#88dd88'
  EMOJI = "\u{1F9D9}" # U+1F9D9 U+200D U+2642 U+FE0F

  def initialize klass
    super()
    @klass = klass
    @name = klass['name']
  end

  def activate
    PlayerClassWindow.new @klass
  end
end

class SearchUI::SpellRow < SearchUI::SearchUIRow
  def initialize spell
    super()
    @spell = spell
    @name = spell['name']
  end

  def activate
    SpellWindow.new @spell
  end

  COLOR = '#a8a866'
  EMOJI = "\u{1F52E}"
end
