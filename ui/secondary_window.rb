# An abstract class for displaying info on Spells, Player Classes, Foe Classes, etc.
require 'forwardable'
require_relative 'builder_view'

class SecondaryWindow < Gtk::Window
  extend Forwardable

  def_delegators :@view, :dict, :obj, :scroll

  def initialize view
    super()
    @view = view
    raise RuntimeError.new("Bad class for view #{@view.class}") unless @view.is_a?(BuilderView)
    set_child view
    init_signals
    set_titlebar
    set_default_width 600
    set_height_request 600
    set_visible true
    override_font Pango::FontDescription.new "20px"
    signal_connect("key-press-event") do |widget, event|
      if event.state.control_mask?
        case event.keyval
        when Gdk::Keyval::KEY_equal # (+)
          @font_size ||= 20
          @font_size += 2
          override_font Pango::FontDescription.new "#{@font_size}px"
        when Gdk::Keyval::KEY_minus
          @font_size ||= 20
          @font_size -= 2
          override_font Pango::FontDescription.new "#{@font_size}px"
        end
      end
    end
  end

  private

  # E.g. add_accelerator "<Control>C", 'cast MenuItem'
  def add_accelerator accel_string, menu_item
    key, mod = Gtk.accelerator_parse(accel_string)
    obj(menu_item).add_accelerator("activate", @accel_group, key, mod, Gtk::AccelFlags::VISIBLE)
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

  def set_titlebar
    titlebar = obj('HeaderBar')
    return if titlebar.nil?
    titlebar.parent.remove titlebar
    super titlebar
    @accel_group = Gtk::AccelGroup.new
    add_accel_group @accel_group
  end
end
