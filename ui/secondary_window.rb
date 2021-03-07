# An abstract class for displaying info on Spells, Player Classes, Foe Classes, etc.

class SecondaryWindow < Gtk::Window

  def initialize dict
    super()
    @dict = dict
    @builder = Gtk::Builder.new(file: self.class::BUILDER_FILE)
    add @builder.get_object('top')
    init_signals
    set_default_width 600
    set_height_request 600
    set_visible true
  end

  private

  def init_signals
    signal_connect("key-press-event") do |widget, event|
      if event.keyval == Gdk::Keyval::KEY_Escape
        close
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
    '<span color="#aaaaaa">%s</span> %s' % [label, @dict[key]]
  end

  def obj id
    @builder.get_object(id)
  end

  def set id, markup
    obj(id).set_markup markup
  end
end
