# An abstract class for displaying info on Spells, Player Classes, Foe Classes, etc.

class SecondaryWindow < Gtk::Window

  def initialize dict
    super()
    @dict = dict
    @builder = Gtk::Builder.new(file: self.class::BUILDER_FILE)
    add @builder.get_object('top')
    init_signals
    set_titlebar
    set_default_width 600
    set_height_request 600
    set_visible true
  end

  private

  # E.g. add_accelerator "<Control>C", 'cast MenuItem'
  def add_accelerator accel_string, menu_item
    key, mod = Gtk.accelerator_parse(accel_string)
    obj(menu_item).add_accelerator("activate", @accel_group, key, mod, Gtk::AccelFlags::VISIBLE)
  end

  def gray text
    '<span color="#aaaaaa">%s</span>' % text
  end

  def init_signals
    signal_connect("key-press-event") do |widget, event|
      if event.keyval == Gdk::Keyval::KEY_Escape
        close
      elsif event.keyval == Gdk::Keyval::KEY_Down
        scroll 30
      elsif event.keyval == Gdk::Keyval::KEY_Up
        scroll -30
      elsif event.keyval == Gdk::Keyval::KEY_Left
        scroll nil, -30
      elsif event.keyval == Gdk::Keyval::KEY_Right
        scroll nil, 30
      elsif event.state.control_mask?
        case event.keyval
        when Gdk::Keyval::KEY_w
          close
        end
      end
    end
  end

  def keyval_markup key, label=nil
    label ||= key.capitalize
    '%s %s' % [gray(label), @dict[key]]
  end

  def obj id
    @builder.get_object(id)
  end

  def scroll vinc, hinc=nil
    @scroll_viewport ||= obj('Viewport')
    if vinc
      vadj = @scroll_viewport.vadjustment
      vadj.set_value vadj.value + vinc
    end
    if hinc
      hadj = @scroll_viewport.hadjustment
      hadj.set_value hadj.value + hinc
    end
  end

  def set id, markup
    obj(id).set_markup markup
  end

  def set_titlebar
    titlebar = obj('HeaderBar')
    return if titlebar.nil?
    titlebar.parent.remove titlebar
    super titlebar
    @accel_group = Gtk::AccelGroup.new
    add_accel_group @accel_group
  end
end
