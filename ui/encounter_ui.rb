require 'gtk3'
require_relative './abstract_character_list_ui'

class EncounterUI < AbstractCharacterListUI

  def init widget
    super widget, Game.instance.encounter, EncounterUI::MemberRow
    widget.set_sort_func {|a,b|
      init_a, init_b = [a,b].map {|w| Game.instance.encounter.initiative_for w.character }
      init_b <=> init_a
    }
  end

  def on_initiative_blur row
    Game.instance.encounter.set_initiative row.character, row.initiative_value
    reload
  end
end

class EncounterUI::MemberRow < AbstractCharacterRow
  def initialize character
    super()
    @character = character
    set_visible true
    box = Gtk::Box.new :horizontal
    box.set_visible true
    add box
    # Add Initiative-order entry
    @initiative_entry = Gtk::Entry.new.tap do |entry|
      entry.set_visible true
      entry.set_width_chars 2
      entry.set_text Game.instance.encounter.initiative_for(character).to_i.to_s
      entry.signal_connect('focus-out-event') do |widget, event|
        Game.instance.encounter.set_initiative character, widget.text.to_i
        parent.invalidate_sort
      end
      box.add entry
    end
    # Make event box to handle button press
    evt_box = Gtk::EventBox.new.tap do |evt_box|
      evt_box.set_visible true
      box.add evt_box
      evt_box.signal_connect('button-press-event') do |widget|
        puts "btton press==========="
      end
    end
    # Make label
    @name_label = Gtk::Label.new.tap do |label|
      label.set_markup @character.name
      label.set_xalign 0.0
      label.set_hexpand true
      label.set_visible true
      label.set_ellipsize Pango::EllipsizeMode::END
      evt_box.add label
    end
    reset_name_text
    # Add Remove button
    @remove_button = Gtk::Button.new.tap do |button|
      button.set_image Gtk::Image.new stock: 'gtk-delete'
      button.set_can_focus false
      button.set_visible true
      button.set_tooltip_text 'Delete'
      button.signal_connect('clicked') do |widget|
        EncounterUI.instance.remove @character
      end
      box.add button
    end
    # Add signals
    signal_connect('activate') do |widget|
      puts "activated++++++="
    end
    signal_connect('key-press-event') do |widget, event|
      case event.keyval
      when Gdk::Keyval::KEY_Delete
        @remove_button.clicked
      when Gdk::Keyval::KEY_i
        @initiative_entry.grab_focus
      end
    end
  end
end
