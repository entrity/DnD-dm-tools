require "gtk3"
require_relative './monsters_ui'
require_relative './character_view_loader'
require_relative '../lib/characters'
require_relative '../lib/game'

##########################
# Get CSS
style_provider = Gtk::CssProvider.new
style_provider.load_from_file Gio::File.new_for_path 'style.css'
Gtk::StyleContext.add_provider_for_screen(
    Gdk::Screen.default,
    style_provider,
)

def add_character_dialog
  builder_file = "#{File.expand_path(File.dirname(__FILE__))}/character_dialog.ui"
  builder = Gtk::Builder.new(:file => builder_file)
  # require 'pry'; binding.pry
  dialog = builder.objects.find {|o| o.is_a? Gtk::Dialog }
#   # dialog.show_all
  dialog.run do |response|
    puts response
    dialog.destroy
  end
#   # dialog.signal_connect('response') { dialog.destroy }
#   puts dialog.run
end

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

def toggle_pcs
end

def toggle_visible source, revealer
  revealer.set_reveal_child !revealer.reveal_child?
end

##########################
# Construct a Gtk::Builder instance and load our UI description
builder_file = "#{File.expand_path(File.dirname(__FILE__))}/main.ui"
@builder = builder = Gtk::Builder.new(:file => builder_file)
builder.connect_signals {|handler| method(handler) }
window = builder.get_object("window")
monsters_search_entry = builder.get_object('monsters-search')

# Connect signal handlers to the constructed widgets
window.signal_connect("destroy") { Gtk.main_quit }
##########################
# cf. https://riptutorial.com/gtk3/example/16426/simple-binding-to-a-widget-s-key-press-event
window.signal_connect("key-press-event") do |widget, event|
  case event.keyval
  when Gdk::Keyval::KEY_m # Search monsters
    monsters_search_entry.grab_focus if event.state.control_mask?
  when Gdk::Keyval::KEY_q, Gdk::Keyval::KEY_w # Exit
    Gtk.main_quit if event.state.control_mask?
  when Gdk::Keyval::KEY_1 # Page 1
    notebook.set_page(0)
  when Gdk::Keyval::KEY_2 # Page 2
    notebook.set_page(1)
  end
end

##########################
# Initialize Monsters UI
monster_library = MonsterLibrary.new
MonstersUI.new(builder, monster_library)
builder.get_object('monsters-search').grab_focus # todo rm

##########################
# Initialize Game
@game = Game.load ARGV[0]

##########################
# Start main loop
CharacterViewLoader.new @builder, Monster.new(monster_library.list.first)
Gtk.main