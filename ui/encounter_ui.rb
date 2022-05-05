require 'gtk3'
require_relative './abstract_character_list_ui'

class EncounterUI < AbstractCharacterListUI

  def_delegators :'Game.instance.encounter', :cast

  def init widget
    super widget, Game.instance.encounter.npcs, EncounterUI::MemberRow
    widget.set_sort_func {|a,b|
      init_a, init_b = [a,b].map {|w| Game.instance.encounter.initiative_for w.character }
      init_b <=> init_a
    }
  end

  def add character
    if super
      MainUI.instance.invalidate_encounter_summary
    end
  end

  def next; prev_next 1; end

  def on_initiative_blur row
    Game.instance.encounter.set_initiative row.character, row.initiative_value
    reload
  end

  def prev; prev_next -1; end

  def remove character
    if super
      MainUI.instance.invalidate_encounter_summary
    end
  end

  private

  def prev_next inc
    selected = @widget.selected_row
    @widget.move_cursor Gtk::MovementStep::DISPLAY_LINES, inc
    @widget.activate_cursor_row
    if selected == @widget.selected_row # Could be none is selected, or the selection was already at the end of the list when the function was called
      @widget.move_cursor Gtk::MovementStep::BUFFER_ENDS, 0 <=> inc # Go to first/last row
    end
    @widget.toggle_cursor_row
    @widget.activate_cursor_row
    show_character(@widget.selected_row.character) if @widget.selected_row
  end

  def show_character character
    MainUI.instance.set_character character
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
        MainUI.instance.set_character(@character)
      end
    end
    # Make label
    @name_label = Gtk::Label.new.tap do |label|
      label.set_markup @character.name
      label.set_xalign 0.0
      label.set_hexpand true
      label.set_visible true
      label.set_ellipsize ::Pango::EllipsizeMode::END
      evt_box.add label
    end
    reset_name_text
    # Add Remove-to-cast button
    @to_cast_button = Gtk::Button.new.tap do |button|
      button.set_image Gtk::Image.new stock: 'gtk-go-up'
      button.set_can_focus false
      button.set_visible true
      button.set_tooltip_text 'Move to "cast only"'
      button.signal_connect('clicked') do |widget|
        EncounterUI.instance.remove @character
        CastUI.instance.add @character
      end
      box.add button
    end
    # Add Remove button
    @remove_button = Gtk::Button.new.tap do |button|
      button.set_image Gtk::Image.new stock: 'gtk-delete'
      button.set_can_focus false
      button.set_visible true
      button.set_tooltip_text 'Delete'
      button.signal_connect('clicked') do |widget|
        ui = EncounterUI.instance
        i = ui.children.index { |c| c.character == @character }
        ui.remove @character
        next_i = [i, ui.children.length-1].min
        ui.children[next_i].grab_focus
      end
      box.add button
    end
    # Add signals
    signal_connect('activate') do |widget|
      MainUI.instance.set_character(@character)
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

  protected

  def build_name_text
    "%s <i>%d</i>" % [colored_character(@character, true), @character.hp.to_i]
  end
end
