#!/usr/bin/env ruby

require "gtk3"
require 'singleton'
require_relative '../lib/characters'
require_relative '../lib/game'
require_relative '../lib/util'
require_relative './cast_ui'
require_relative './encounter_ui'
require_relative './encounters_ui'
require_relative './console'
require_relative './file_io'
require_relative './markup'
require_relative './menu_handlers'
require_relative './search_ui'

class MainUI
  include Singleton
  include Console::Commands
  include FileIO
  include Markup
  include MenuHandlers

  attr_reader :character

  def initialize
    init_css
    init_gui
    @search_ui = SearchUI.new @builder
    @search_ui.entry.grab_focus
    CastUI.instance.init @builder.get_object 'cast ListBox'
    EncounterUI.instance.init @builder.get_object 'encounter ListBox'
    EncountersUI.instance.init @builder.get_object 'encounters ListBox'
    invalidate_encounter_summary
    $stdout.puts "MainUI#initialize"
  end

  def invalidate_encounter_summary
    encounter = Game.instance.encounter
    difficulty = encounter.difficulty
    @encounter_summary ||= @builder.get_object('encounter Label')
    difficulties = [['EASY'], ['MED', 'MEDIUM'], ['HARD'], ['DEADLY']].map {|arr|
      dlvl = Encounter.const_get(arr.last)
      cr = encounter.cr_for_party(dlvl)
      cr = dlvl == difficulty ? colored_difficulty(difficulty, cr) : cr
      "#{arr.first} #{cr}"
    }.join(' / ')
    @encounter_summary.set_markup <<~EOF
      Encounter
      XP #{encounter.xp.to_i} / CR #{colored_difficulty difficulty, encounter.cr}
      #{difficulties}
    EOF
  end

  def new_encounter
    enc = Encounter.new Game.instance.cast.select(&:is_pc)
    EncountersUI.instance.load enc
  end

  def puts *args
    @dice_console.append *args
  end

  def run
    # Start main loop
    @gtk_main_loop = GLib::MainLoop.new
    begin
      @gtk_main_loop.run
    ensure
      Game.instance.dump 'autosave.sav'
    end
  end

  def set_character character
    @character = character
    set_content CharacterView.new character
  end

  def set_content child_widget
    @content_wiget ||= @builder.get_object('content Box')
    @content_wiget.children.each {|c| @content_wiget.remove c }
    @content_wiget.add child_widget, expand: true
  end

  private

  # Get CSS
  def init_css
    style_provider = Gtk::CssProvider.new
    style_provider.load_from_file Gio::File.new_for_path File.join File.dirname(__FILE__), 'style.css'
    Gtk::StyleContext.add_provider_for_screen(
        Gdk::Screen.default,
        style_provider,
    )
  end

  def init_gui
    # Construct a Gtk::Builder instance and load our UI description
    builder_file = File.join XML_DIR, "main.ui"
    @builder = Gtk::Builder.new(:file => builder_file)
    @builder.connect_signals {|handler| method(handler) }
    @window = @builder.get_object("window")
    @window.set_title "D&D"
    @window.override_font Pango::FontDescription.new "20px"
    @dice_console = DiceConsole.create @builder.get_object('dice console input'), @builder.get_object('dice console output')
    @encounters_list = @builder.get_object('encounters-list Menu')
    # Exit on close window
    @window.signal_connect("destroy") { Gtk.main_quit }
    # cf. https://riptutorial.com/gtk3/example/16426/simple-binding-to-a-widget-s-key-press-event
    @window.signal_connect("key-press-event") do |widget, event|
      if event.state.control_mask?
        case event.keyval
        when Gdk::Keyval::KEY_k # Command input
          @dice_console.input.grab_focus
        when Gdk::Keyval::KEY_f # Search
          @search_ui.entry.grab_focus
        when Gdk::Keyval::KEY_q, Gdk::Keyval::KEY_w # Exit
          @gtk_main_loop.quit
        when Gdk::Keyval::KEY_space # Toggle console
          toggle_console_visibility
        when Gdk::Keyval::KEY_Left
          EncounterUI.instance.prev unless widget.focus == @dice_console.input
          false # Allow event to propagate
        when Gdk::Keyval::KEY_Right
          EncounterUI.instance.next unless widget.focus == @dice_console.input
          false # Allow event to propagate
        when Gdk::Keyval::KEY_equal # (+)
          @font_size ||= 18
          @font_size += 2
          @window.override_font Pango::FontDescription.new "#{@font_size}px"
        when Gdk::Keyval::KEY_minus
          @font_size ||= 18
          @font_size -= 2
          @window.override_font Pango::FontDescription.new "#{@font_size}px"
        when Gdk::Keyval::KEY_1
        when Gdk::Keyval::KEY_2
        end
      end
    end
  end

  def on_terrain_changed trigger
    if iter = trigger.active_iter
      $stderr.puts trigger.model.get_value(iter, 0).inspect
    end
  end

  def toggle_cast_v_encounters trigger
    case trigger.label
    when '_Cast'; @builder.get_object('cast Box').set_visible(trigger.active?)
    else; @builder.get_object('encounters Box').set_visible(trigger.active?)
    end
  end

  def toggle_visible trigger
    case trigger.label
    when 'Encounter'
      target = @builder.get_object('encounter-summary Box')
    end
    target.set_visible !target.visible?
  end
end

Game.instance.load ARGV[0]
MainUI.instance.run
