require 'gtk3'
require_relative './abstract_character_list_ui'
require_relative './encounter_ui'

class CastUI < AbstractCharacterListUI

  def init widget
    super widget, Game.instance.cast, CastUI::MemberRow
    widget.set_sort_func {|a,b|
      if a.character.is_pc != b.character.is_pc
        a.character.is_pc ? -1 : 1
      else
        a.character.label.downcase <=> b.character.label.downcase
      end
    }
    widget.signal_connect('key-press-event') do |widget, event|
      if event.keyval == Gdk::Keyval::KEY_u && event.state.control_mask?
        undelete
      end
    end
  end

  def remove character
    @recycle ||= [] # Storage for deleted characters
    @recycle << character
    super
  end

  def undelete
    character = @recycle.pop
    add character if character
  end
end

class CastUI::MemberRow < AbstractCharacterRow
  def initialize character
    super()
    @character = character
    set_visible true
    box = Gtk::Box.new :horizontal
    box.set_visible true
    add box
    # Make event box
    evt_box = Gtk::EventBox.new.tap do |evt_box|
      evt_box.set_visible true
      box.add evt_box
      evt_box.signal_connect('button-press-event') do |widget|
        activate(widget)
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
    # Add in-encounter toggle
    @encounter_toggle = Gtk::ToggleButton.new().tap do |button|
      button.set_image Gtk::Image.new stock: 'gtk-about'
      button.clicked if EncounterUI.instance.include?(@character)
      button.set_can_focus false
      button.set_visible true
      button.set_border_width 0
      button.set_tooltip_text 'Ctrl+E'
      button.signal_connect('toggled') do |widget|
        if widget.active?
        #   EncounterUI.instance.add @character
        # else
        #   EncounterUI.instance.remove @character
        end
      end
      box.add button
    end
    @cold_storage_button = Gtk::Button.new().tap do |button|
      button.set_image Gtk::Image.new stock: 'gtk-delete'
      button.set_can_focus false
      button.set_visible true
      button.set_tooltip_text 'Delete'
      button.signal_connect('clicked') do |widget|
        CastUI.instance.remove @character
      end
      box.add button
    end
    # Add signals
    signal_connect('activate') do |widget|
      activate(widget)
    end
    signal_connect('key-press-event') do |widget, event|
      case event.keyval
      when Gdk::Keyval::KEY_Delete
        @cold_storage_button.clicked
      when Gdk::Keyval::KEY_e
        @encounter_toggle.clicked
      end
    end

    def activate(widget)
      require 'pry'; binding.pry
      MainUI.instance.set_character @character
    end
  end
end
