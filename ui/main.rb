#!/usr/bin/env ruby

require "gtk3"
require_relative './search_ui'
require_relative '../lib/characters'
require_relative '../lib/game'
require_relative './autocomplete'
require_relative './character_dialog'
require_relative './character_view_loader'
require_relative './cast_ui'
require_relative './console'
require_relative './encounter_ui'

include CharacterDialogFunctions
include CharacterView
include Commands
include EncounterUI::Functions

##########################
# Get CSS
style_provider = Gtk::CssProvider.new
style_provider.load_from_file Gio::File.new_for_path File.join File.dirname(__FILE__), 'style.css'
Gtk::StyleContext.add_provider_for_screen(
    Gdk::Screen.default,
    style_provider,
)

# File > Open
def load_dialog
  dialog = Gtk::FileChooserDialog.new title: 'Load', parent: nil, action: :open,
  buttons: [[Gtk::Stock::OPEN, Gtk::ResponseType::ACCEPT], [Gtk::Stock::CANCEL, Gtk::ResponseType::CANCEL]]
  fpath = Gtk::ResponseType::ACCEPT == dialog.run && dialog.filename
  dialog.destroy
  puts "loading #{fpath}"
  Game.load fpath
end

# File > Save
def save_dialog(widget, save_as=nil)
  if save_as.nil? || Game.instance.fpath.nil?
    puts 'fpath is nil'
    dialog = Gtk::FileChooserDialog.new title: 'Save', parent: nil, action: :save,
    buttons: [[Gtk::Stock::SAVE, Gtk::ResponseType::ACCEPT], [Gtk::Stock::CANCEL, Gtk::ResponseType::CANCEL]]
    return unless Gtk::ResponseType::ACCEPT == dialog.run
    Game.instance.fpath = dialog.filename
    dialog.destroy
  end
  puts "Saving to #{Game.instance.fpath}"
  Game.instance.dump
end

def load_latest_encounter
  EncounterUI.instance.load_encounter
end

def toggle_pcs
end

def toggle_console_visibility
  console = @builder.get_object 'console'
  method(:toggle_visible).unbind.bind(console).call
  @cmd_console.input.grab_focus if console.reveal_child?
end

def toggle_visible *args
  set_reveal_child !reveal_child?
end

##########################
# Construct a Gtk::Builder instance and load our UI description
builder_file = File.join XML_DIR, "main.ui"
@builder = $main_builder = Gtk::Builder.new(:file => builder_file)
@builder.connect_signals {|handler| method(handler) }
window = @builder.get_object("window")
@search_entry = @builder.get_object('search Entry')
@cmd_console = Commands::Console.create @builder.get_object('console input'), @builder.get_object('console output')
@dice_console = Commands::DiceConsole.create @builder.get_object('dice console input'), @builder.get_object('dice console output')

# Connect signal handlers to the constructed widgets
window.signal_connect("destroy") { Gtk.main_quit }
##########################
# cf. https://riptutorial.com/gtk3/example/16426/simple-binding-to-a-widget-s-key-press-event
window.signal_connect("key-press-event") do |widget, event|
  if event.state.control_mask?
    case event.keyval
    when Gdk::Keyval::KEY_k # Command input
      @dice_console.input.grab_focus
    when Gdk::Keyval::KEY_f # Search
      @search_entry.grab_focus
    when Gdk::Keyval::KEY_q, Gdk::Keyval::KEY_w # Exit
      @gtk_main_loop.quit
    when Gdk::Keyval::KEY_space # Toggle console
      toggle_console_visibility
    when Gdk::Keyval::KEY_1 # Page 1
      notebook.set_page(0)
    when Gdk::Keyval::KEY_2 # Page 2
      notebook.set_page(1)
    end
  end
end

##########################
# Initialize Game
Game.instance.load ARGV[0]
Commands::Console.init(Game.instance)

##########################
# Initialize UIs
Thread.new do
  SearchUI.new(@builder)
  CastUI.init(@builder)
  EncounterUI.instance.init(@builder)
  CharacterViewLoader.init(@builder)
  Game.instance.cast.each {|m| CastUI.instance.add m }
  CastUI.instance.reload
end
@builder.get_object('dice console input').grab_focus

##########################
# Start main loop
@gtk_main_loop = GLib::MainLoop.new
begin
  @gtk_main_loop.run
ensure
  Game.instance.dump 'autosave.sav'
end
