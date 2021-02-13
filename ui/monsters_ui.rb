require_relative '../lib/monster_library'
require_relative '../lib/characters'

class MonstersUI

  def initialize(builder, encounter)
    @lib = MonsterLibrary.new
    @container = builder.get_object 'monsters-list'
    @encounter = encounter
    add_monster @lib.list.first
    add_monster @lib.list[1]
    add_monster @lib.list[2]
  end

  def add_monster monster
    # Row
    row = Gtk::ListBoxRow.new
    row.set_visible true
    row.set_can_focus true
    row.set_focus_on_click true
    # Label
    lbl = Gtk::Button.new label: monster['name']
    lbl.set_visible true
    lbl.set_can_focus true
    lbl.set_focus_on_click true
    lbl.signal_connect("key-press-event") do |widget, event|
      case event.keyval
      when Gdk::Keyval::KEY_e
        @encounter.add Monster.new(monster)
      when Gdk::Keyval::KEY_w
        show_window(monster)
      end
    end
    lbl.signal_connect("focus") do |widget, event|
      puts monster['name']
    end
    row.signal_connect("focus") do |widget, event|
      puts monster['name']
    end
    row.add lbl
    @container.add row
  end

  def show_window monster
    window = Gtk::Window.new
    window.set_visible true
    lbl = Gtk::Label.new
    lbl.set_markup '<b>foo</b>bar'
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
