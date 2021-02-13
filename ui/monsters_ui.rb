require_relative '../lib/monster_library'
require_relative '../lib/characters'

class MonstersUI
  def initialize(builder, encounter)
    @encounter = encounter
    @container = builder.get_object 'monsters-list'
    @search = builder.get_object 'monsters-search'
    @lib = MonsterLibrary.new
    @lib.list.sort {|a,b| a['name'] <=> b['name'] }.each do |m|
      @container.add MonsterRow.new m, @encounter
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

class MonsterRow < Gtk::ListBoxRow
  attr_reader :monster

  def initialize monster, encounter
    super()
    @encounter = encounter
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
        @encounter.add Monster.new(monster)
      when Gdk::Keyval::KEY_w
        self.show_window
      end
    end
    add lbl
  end

  def show_window
    puts "show_window"
    puts @monster.inspect
    window = Gtk::Window.new
    window.set_visible true
    lbl = Gtk::Label.new
    lbl.set_markup "<b>#{@monster['name']}</b>\nbar"
    lbl.set_visible true
    window.add lbl
    window.signal_connect("key-press-event") do |widget, event|
      case event.keyval
      when Gdk::Keyval::KEY_q, Gdk::Keyval::KEY_w
        window.close
      end
    end
  end
end
