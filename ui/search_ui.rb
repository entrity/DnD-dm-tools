require 'gtk3'
require_relative '../lib/character/monster'
require_relative '../lib/character/player_class'
require_relative '../lib/character/player_class_library'
require_relative '../lib/monster_library'
require_relative '../lib/spell_library'
require_relative './character_view'
require_relative './player_class_view'
require_relative './spell_view'

class SearchUI
  attr_reader :entry

  def initialize(builder)
    @builder = builder
    @entry = builder.get_object 'search Entry'
    Thread.new { load_autocomplete }
  end

  private

  def load_autocomplete
    autocomplete_model = Gtk::ListStore.new String, SearchUI::SearchUIRow, String
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
      x.set_value 2, obj.name.downcase
    end
    completion = Gtk::EntryCompletion.new
    completion.set_minimum_key_length 0
    completion.set_text_column 0
    completion.set_inline_completion true
    completion.set_inline_selection true
    completion.set_model autocomplete_model
    completion.set_match_func { |*args| match_func *args }
    completion.signal_connect('cursor-on-match') { |completion, model, iter|
      row = model.get_value iter, 1
      row.show_in_main
    }
    completion.signal_connect("match-selected") do |completion, treemodel, treeiter|
      obj = treemodel.get_value(treeiter, 1)
      obj.activate
    end
    @entry.set_completion completion
  end

  def match_func(entry_completion, entry_value, list_obj)
    entry_text = entry_completion.entry.text
    downcase_name = list_obj.get_value(2)
    return downcase_name.include?(entry_text.downcase)
  end
end

class SearchUI::SearchUIRow
  attr_reader :name
  attr_reader :sort_key

  def activate
    SecondaryWindow.new view
  end

  def show_in_main
    MainUI.instance.set_selection @item
    MainUI.instance.set_content view
  end

  private

  def view
    raise NotImplementedError.new
  end
end

class SearchUI::MonsterRow < SearchUI::SearchUIRow
  def initialize monster
    super()
    @item = @monster = monster
    @name = monster['name']
  end

  def activate
    EncounterUI.instance.add Monster.build @name
  end

  COLOR = '#a8a866'
  EMOJI = "\u{1F47B}"

  def view
    dict = @monster.to_h.transform_keys(&:to_s)
    CharacterView.new Monster.new.load_open5e(dict)
  end
end

class SearchUI::PlayerClassRow < SearchUI::SearchUIRow
  COLOR = '#88dd88'
  EMOJI = "\u{1F9D9}" # U+1F9D9 U+200D U+2642 U+FE0F

  def initialize klass_hash
    super()
    @item = @klass_hash = klass_hash
    @name = klass_hash['name']
  end

  def view
    PlayerClassView.new @klass_hash
  end
end

class SearchUI::SpellRow < SearchUI::SearchUIRow
  def initialize spell
    super()
    @item = @spell = spell
    @name = spell['name']
  end

  def view
    SpellView.new @spell
  end

  COLOR = '#a8a866'
  EMOJI = "\u{1F52E}"
end
