module CharacterDialog

  class DialogLoader
    def initialize builder, character
      @builder = builder
      @char = character
    end

    def dump

    end

    def load
      set 'player class', @char.klass if @char.is_a? Pc
      set 'monster class', @char.klass if @char.is_a? Monster
      set 'type', @char.type
      set 'subtype', @char.subtype
      set 'group', @char.group
      set 'maxhp', @char.max_hp
      set 'hp', @char.hp
      set 'hit dice', @char.hit_dice
      set 'str', @char.str
      set 'dex', @char.dex
      set 'con', @char.con
      set 'int', @char.int
      set 'wis', @char.wis
      set 'cha', @char.cha
    end

    private

    def set id, value
      @builder.get_object(id).set_text(value.to_s) unless value.nil?
    end
  end

  # Open dialog
  def open_character_dialog character=nil
    @@character_dialog ||= begin
      builder_file = "#{File.expand_path(File.dirname(__FILE__))}/character_dialog.ui"
      @@builder = Gtk::Builder.new(:file => builder_file)
      @@builder.connect_signals {|handler| method(handler) }
      dialog = @@builder.objects.find {|o| o.is_a? Gtk::Dialog }
      dialog.add_buttons [Gtk::Stock::OK, Gtk::ResponseType::ACCEPT], [Gtk::Stock::CANCEL, Gtk::ResponseType::CANCEL]
      dialog
    end
    dialog = @@character_dialog
    dialog.signal_connect('response') { |dialog, response|
      dialog.hide
      DialogLoader.new(dialog, character).dump if Gtk::ResponseType::ACCEPT == response
    }
    character ||= Character.new
    DialogLoader.new(@@builder, character).load
    dialog.show_all
  end

  def toggle_character_inclusion_in_cast widget
    # if w
    # @game.cast
    require 'pry'; binding.pry
  end
end
