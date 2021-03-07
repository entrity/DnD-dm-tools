require 'gtk3'
require_relative '../lib/constants'

class SpellWindow < Gtk::Window

  BUILDER_FILE = File.join(XML_DIR, 'spell_window.ui')

  def initialize spell
    super()
    @builder = Gtk::Builder.new(file: BUILDER_FILE)
    @spell = spell
    init_signals
    add @builder.get_object('top')
    set 'name Label', '<big><a href="https://open5e.com/spells/%s">%s</a></big>' % [@spell['slug'], @spell['name']]
    set 'desc Label', @spell['desc']
    set 'higher_level Label', keyval_markup('higher_level', '<i>At higher levels:</i>')
    flow_labels = @builder.get_object('FlowBox').children
    flow_labels.shift.first.set_markup "%s %s | %s" % @spell.values_at("level", "school", "dnd_class")
    [
      "range",
      "casting_time",
      "duration",
      "components",
      "material",
      "concentration",
      "ritual",
      "page",
      "archetype",
      "circles",
    ].each { |key| flow_labels.shift.children.first.set_markup keyval_markup key }
    set_default_size 600, 300
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
    '<span color="#aaaaaa">%s</span> %s' % [label, @spell[key]]
  end

  def set id, markup
    @builder.get_object(id).set_markup markup
  end
end
