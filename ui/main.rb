require "gtk3"
require_relative 'monsters_ui'
require_relative 'encounter'

style_provider = Gtk::CssProvider.new
style_provider.load_from_file Gio::File.new_for_path 'style.css'
Gtk::StyleContext.add_provider_for_screen(
    Gdk::Screen.default,
    style_provider,
)
builder_file = "#{File.expand_path(File.dirname(__FILE__))}/backup.ui"

# Construct a Gtk::Builder instance and load our UI description
builder = Gtk::Builder.new(:file => builder_file)

window = builder.get_object("window")
notebook = builder.get_object('notebook')
monsters_search_entry = builder.get_object('monsters-search')
characters_search_entry = builder.get_object('characters-search')

# Connect signal handlers to the constructed widgets
window.signal_connect("destroy") { Gtk.main_quit }


# tog = builder.get_object("tog-tmp")
# tog.signal_connect("focus") do |widget, event|
#   puts "focused++++++++++++++"
# end

##########################
# cf. https://riptutorial.com/gtk3/example/16426/simple-binding-to-a-widget-s-key-press-event
window.signal_connect("key-press-event") do |widget, event|
  case event.keyval
  when Gdk::Keyval::KEY_c # Go to characters
    characters_search_entry.grab_focus unless window.focus.is_a?(Gtk::SearchEntry)
  when Gdk::Keyval::KEY_m # Go to monsters
    monsters_search_entry.grab_focus unless window.focus.is_a?(Gtk::SearchEntry)
  when Gdk::Keyval::KEY_q, Gdk::Keyval::KEY_w # Exit
    Gtk.main_quit if event.state.control_mask?
  when Gdk::Keyval::KEY_Escape # Unfocus
    notebook.grab_focus
  when Gdk::Keyval::KEY_1 # Page 1
    notebook.set_page(0)
  when Gdk::Keyval::KEY_2 # Page 2
    notebook.set_page(1)
  end
end
##########################

@encounter = Encounter.new
MonstersUI.new(builder, @encounter)
builder.get_object('monsters-search').grab_focus # todo rm
##########################
# button = builder.get_object("button2")
# button.signal_connect("clicked") { puts "Hello World" }

# button = builder.get_object("quit")
# button.signal_connect("clicked") { Gtk.main_quit }

Gtk.main