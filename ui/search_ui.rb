require_relative '../lib/monster_library'
require_relative '../lib/characters'
require_relative './character_view_loader'

class SearchUI
  def initialize(builder, monster_library)
    @builder = builder
    @container = builder.get_object 'search list'
    @search = builder.get_object 'search Entry'
    monster_library.list.sort {|a,b| a['name'] <=> b['name'] }.each do |m|
      @container.add MonsterListRow.new m, @builder
    end
    # Signals
    @container.set_filter_func do |item, a, b|
      search_term = @search.text.strip
      0 == search_term.length || item.monster['name'] =~ Regexp.new(search_term, 'i')
    end
    @search.signal_connect("search-changed") do |widget, event|
      @container.invalidate_filter
    end
  end
end

class MonsterListRow < Gtk::ListBoxRow
  attr_reader :monster

  def initialize monster, builder
    super()
    @builder = builder
    @monster = monster
    # Label
    lbl = Gtk::Button.new label: monster['name']
    lbl.set_visible true
    lbl.set_can_focus false
    lbl.set_focus_on_click false
    lbl.set_xalign 0.0
    self.set_visible true
    self.set_can_focus true
    self.set_focus_on_click true
    # Signals
    self.signal_connect("key-press-event") do |widget, event|
      case event.keyval
      when Gdk::Keyval::KEY_e
        Game.encounter.add Monster.new(monster)
      when Gdk::Keyval::KEY_w
        self.show_in_window
      when Gdk::Keyval::KEY_Return
        self.show
      end
    end
    lbl.signal_connect("clicked") do |widget, event|
      self.grab_focus
      show
    end
    add lbl
  end

  def show
    CharacterViewLoader.content_set @builder, Monster.new(@monster)
  end

  def show_in_window
    puts "show_window"
  end
end
