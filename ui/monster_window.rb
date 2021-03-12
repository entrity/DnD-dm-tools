require 'gtk3'
require 'forwardable'
require_relative '../lib/constants'
require_relative 'secondary_window'

class MonsterWindow < SecondaryWindow
  extend Forwardable

  def_delegator :@monster, :slug, :name

  def initialize monster
    super
    @monster = monster
    obj('MenuBar')
    set_title monster.name.presence || monster.klass
    set_name
    set_stats
    set_detail
    @builder.connect_signals {|handler| method(handler) }
    add_accelerator "<Control>C", 'cast MenuItem'
    add_accelerator "<Control>Y", 'cast-copy MenuItem'
  end

  private

  def on_add_to_cast_activated widget
    CastUI.instance.add @monster
  end

  def on_add_to_encounter_activated widget
    raise NotImplementedError.new
  end

  def on_copy_to_cast_activated widget
    CastUI.instance.add @monster.dup
  end

  def set_detail
    markup = <<~EOF

    EOF
    obj('detail Label').set_markup(markup)
  end

  def set_name
    markup = <<~EOF
      <big><a href="https://open5e.com/monsters/#{@dict['slug']}">#{name}</a></big>
      <small>
        #{}
      }
      </small>
    EOF
    set 'name Label', markup.gsub(/\n/, '')
  end

  def set_stats
    labels = obj('stats FlowBox').children.map {|x| x.children.first }
    markup = ->(lbl, key) {
      val = @dict[key]
      mod = ((val.to_i - 10) / 2).floor
      "%s\n%s (%s)" % [gray(lbl), val, mod]
    }
    labels.shift.set_markup markup.call("STR", 'strength')
    labels.shift.set_markup markup.call("DEX", 'dexterity')
    labels.shift.set_markup markup.call("CON", 'constitution')
    labels.shift.set_markup markup.call("INT", 'strength')
    labels.shift.set_markup markup.call("WIS", 'wisdom')
    labels.shift.set_markup markup.call("CHA", 'charisma')
  end

  BUILDER_FILE = File.join(XML_DIR, 'monster_window.ui')
end
