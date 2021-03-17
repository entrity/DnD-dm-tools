require 'gtk3'
require_relative '../lib/constants'
require_relative 'secondary_window'
require_relative 'builder_view'

class SpellView < BuilderView

  BUILDER_FILE = File.join(XML_DIR, 'spell_window.ui')

  def initialize spell
    super
    @spell = spell
    set 'name Label', '<big><a href="https://open5e.com/spells/%s">%s</a></big>' % [@spell['slug'], @spell['name']]
    set 'desc Label', @spell['desc']
    set 'higher_level Label', keyval_markup('higher_level', '<i>At higher levels:</i>')
    flowbox = obj('FlowBox')
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
    ].each { |key|
      if markup = keyval_markup(key)
        label = Gtk::Label.new
        label.set_xalign 0.0
        label.set_markup markup
        label.set_visible true
        flowbox.add_child label
      end
    }
  end
end
