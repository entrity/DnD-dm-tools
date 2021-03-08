require 'gtk3'
require_relative '../lib/constants'
require_relative 'secondary_window'

class PlayerClassWindow < SecondaryWindow

  BUILDER_FILE = File.join(XML_DIR, 'player_class_window.ui')

  def initialize player_class
    super
    @klass = player_class
    set 'name Label', '<big><a href="https://open5e.com/spells/%s">%s</a></big>' % [@klass['slug'], @klass['name']]
    flow_labels = obj('FlowBox').children
    set_hp flow_labels.shift.first
    set_proficiencies flow_labels.shift.first
    set_equipment flow_labels.shift.first
    set_table obj('table Box')
    set_class_abilities obj('abilities Label')
    init_signals
  end

  private

  def set_class_abilities widget
    value = @klass['desc']
    widget.set_markup([
      '<big>Class Abilities</big>',
      value
    ].join "\n")
  end

  def set_equipment widget
    value = @klass['equipment']
    value.gsub!(/\*([a-z])\*/, "<i>\\1</i>")
    value.gsub!(/\n(\s*\n)+/, "\n")
    widget.set_markup([
      '<big>Equipment</big>',
      value
    ].join "\n")
  end

  def set_hp widget
    widget.set_markup([
      '<big>Hit Points</big>',
      keyval_markup('hit_dice'),
      keyval_markup('hp_at_1st_level'),
      keyval_markup('hp_at_higher_levels'),
    ].join "\n")
  end

  def set_proficiencies widget
    widget.set_markup([
      '<big>Proficiencies</big>',
      keyval_markup('prof_armor'),
      keyval_markup('prof_weapons'),
      keyval_markup('prof_tools'),
      keyval_markup('prof_saving_throws'),
      keyval_markup('prof_skills'),
    ].join "\n")
  end

  def set_table widget
    lbl = Gtk::Label.new
    lbl.set_markup("<big>The #{@klass['name'].capitalize}</big>")
    lbl.set_xalign 0.0
    lbl.set_visible true
    widget.add lbl
    rows = @klass['table'].split("\n").map {|txt| txt.split(/\s*\|\s*/)[1..-1] }
    grid = Gtk::Grid.new
    add_cell = ->(val, r, c) {
      l = Gtk::Label.new(val)
      l.set_xalign 0.0
      l.set_padding 8, 0
      l.set_visible true
      grid.attach(l, c, r, 1, 1)
    }
    rows.first.each_with_index {|col, c| add_cell.call col, 0, c }
    rows[2..-1].each_with_index do |row, r|
      row.each_with_index {|col, c| add_cell.call col, 1+r, c }
    end
    grid.set_visible true
    widget.add grid
    # widget.set_markup([
    #   "<big>The #{@klass['name'].capitalize}</big>",
    #   value
    # ].join "\n")
  end
end
