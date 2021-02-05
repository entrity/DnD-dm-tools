require "gtk3"

builder_file = "#{File.expand_path(File.dirname(__FILE__))}/main.ui"

# Construct a Gtk::Builder instance and load our UI description
builder = Gtk::Builder.new(:file => builder_file)

# Connect signal handlers to the constructed widgets
window = builder.get_object("window")
window.signal_connect("destroy") { Gtk.main_quit }

notebook = builder.get_object('notebook')

# cf. https://riptutorial.com/gtk3/example/16426/simple-binding-to-a-widget-s-key-press-event
window.signal_connect("key-press-event") do |widget, event|
  case event.keyval
  when Gdk::Keyval::KEY_q, Gdk::Keyval::KEY_w
    Gtk.main_quit if event.state.control_mask?
  when Gdk::Keyval::KEY_e
    notebook.set_page(1)
  when Gdk::Keyval::KEY_p
    notebook.set_page(0)
  end
end


# my_accelerators = Gtk.AccelGroup()
# window.add_accelerator(signal, my_accelerators, *Gtk.accelerator_parse('<Control>+w'), Gtk.AccelFlags.VISIBLE
# button = builder.get_object("button1")
# button.signal_connect("clicked") { puts "Hello World" }

# button = builder.get_object("button2")
# button.signal_connect("clicked") { puts "Hello World" }

# button = builder.get_object("quit")
# button.signal_connect("clicked") { Gtk.main_quit }

Gtk.main