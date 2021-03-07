#!/usr/bin/env ruby

require "gtk3"
require 'singleton'
require_relative '../lib/characters'
require_relative '../lib/game'
require_relative './console'
require_relative './file_io'
require_relative './search_ui'
# require_relative './autocomplete'
# require_relative './character_dialog'
# require_relative './character_view_loader'
# require_relative './cast_ui'
# require_relative './encounter_ui'

# include CharacterDialogFunctions
# include CharacterView
# include Commands
# include EncounterUI::Functions

class MainUI
  include Singleton
  include Console::Commands
  include FileIO

  def initialize
    init_css
    init_gui
    @search_ui = SearchUI.new @builder
    @search_ui.entry.grab_focus
    puts "MainUI#initialize"
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
    # Exit on close window
    @window.signal_connect("destroy") { Gtk.main_quit }
    # cf. https://riptutorial.com/gtk3/example/16426/simple-binding-to-a-widget-s-key-press-event
    @window.signal_connect("key-press-event") do |widget, event|
      if event.state.control_mask?
        case event.keyval
        when Gdk::Keyval::KEY_k # Command input
          # @dice_console.input.grab_focus
        when Gdk::Keyval::KEY_f # Search
          @search_ui.entry.grab_focus
        when Gdk::Keyval::KEY_q, Gdk::Keyval::KEY_w # Exit
          @gtk_main_loop.quit
        when Gdk::Keyval::KEY_space # Toggle console
          toggle_console_visibility
        when Gdk::Keyval::KEY_1
        when Gdk::Keyval::KEY_2
        end
      end
    end
  end

  def toggle_visible *args
    set_reveal_child !reveal_child?
  end
end

Game.instance.load ARGV[0]
MainUI.instance.run

##########################

=begin

def load_latest_encounter
  EncounterUI.instance.load_encounter
end

def toggle_console_visibility
  console = @builder.get_object 'console'
  method(:toggle_visible).unbind.bind(console).call
  @cmd_console.input.grab_focus if console.reveal_child?
end

##########################

@cmd_console = Commands::Console.create @builder.get_object('console input'), @builder.get_object('console output')
@dice_console = Commands::DiceConsole.create @builder.get_object('dice console input'), @builder.get_object('dice console output')

##########################
# Initialize Game
Commands::Console.init(Game.instance)

##########################
# Initialize UIs
Thread.new do
  CastUI.init(@builder)
  EncounterUI.instance.init(@builder)
  CharacterViewLoader.init(@builder)
  Game.instance.cast.each {|m| CastUI.instance.add m }
  CastUI.instance.reload
  puts "ui loaded"
end
@builder.get_object('dice console input').grab_focus

##########################
=end