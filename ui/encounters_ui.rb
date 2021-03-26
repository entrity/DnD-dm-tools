require 'gtk3'
require_relative './abstract_character_list_ui'

class EncountersUI < AbstractCharacterListUI
  def init widget
    super widget, Game.instance.encounters, EncountersUI::MemberRow
    @deleted = []
  end

  def load encounter
    game_members.push(encounter) unless game_members.include?(encounter)
    Game.instance.encounter = encounter
    MainUI.instance.invalidate_encounter_summary
    reload
    EncounterUI.instance.reload
    CastUI.instance.reload
  end

  def remove encounter
    super
    @deleted << encounter
  end

  def update_name encounter
    children.find {|c| c.encounter == encounter }&.reset_text
  end
end

class EncountersUI::MemberRow < AbstractCharacterRow

  attr_reader :encounter

  def initialize encounter
    super()
    @encounter = encounter
    set_visible true
    box = Gtk::Box.new :horizontal
    box.set_visible true
    add box
        # Make event box to handle button press
    evt_box = Gtk::EventBox.new.tap do |evt_box|
      evt_box.set_visible true
      box.add evt_box
      evt_box.signal_connect('button-press-event') do |widget|
        EncountersUI.instance.load(@encounter)
      end
    end
    # "Load" label
    @name_label = Gtk::Label.new.tap do |label|
      label.set_xalign 0.0
      label.set_hexpand true
      label.set_visible true
      label.set_ellipsize Pango::EllipsizeMode::END
      evt_box.add label
    end
    reset_text
    # "Delete" button
    @delete_button = Gtk::Button.new.tap do |button|
      button.set_image Gtk::Image.new stock: 'gtk-delete'
      button.set_can_focus false
      button.set_visible true
      button.set_tooltip_text 'Delete'
      button.signal_connect('clicked') do |widget|
        EncountersUI.instance.remove @encounter
      end
      box.add button
    end
    # Add signals
    signal_connect('activate') do |widget|
      EncountersUI.instance.load(@encounter)
    end
    signal_connect('key-press-event') do |widget, event|
      case event.keyval
      when Gdk::Keyval::KEY_Delete
        @delete_button.clicked
      end
    end
  end

  def reset_text
    @name_label.set_text @encounter.cast.reject(&:is_pc).map(&:name).inspect
  end
end
