require 'gtk3'
require_relative '../lib/constants'
require_relative 'secondary_window'

class SpellWindow < SecondaryWindow

  BUILDER_FILE = File.join(XML_DIR, 'spell_window.ui')

  def initialize spell
    super
    @spell = spell
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
  end
end
