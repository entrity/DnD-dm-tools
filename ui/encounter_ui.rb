require 'gtk3'
require 'forwardable'
require 'singleton'
require_relative '../lib/constants'

class EncounterUI < Gtk::ListBox
  extend Forwardable
  include Singleton

  BUILDER_FILE = File.join XML_DIR, "encounter.ui"

  def_delegators :'Game.instance', :encounter

  def init outer_builder
    @wrapper = outer_builder.get_object('content Box')
    raise KeyError.new 'content Box' if @wrapper.nil?
  end

  def add_character character
    encounter.add character
    reload
  end

  def load_encounter encounter=nil
    Game.instance.encounter = encounter if encounter
    @wrapper.remove @wrapper.child if @wrapper.child
    @inner_builder ||= Gtk::Builder.new(file: BUILDER_FILE)
    @wrapper.add @inner_builder.get_object('top')
    reload
  end

  def remove_character character
    encounter.remove character
    reload
  end

  def reload
    children.each {|c| @listbox.remove c }
    encounter.cast.each {|c| @listbox.add ListBoxRow.new c }
  end

  def set_initiative character, value
    encounter.set_initiative character, value
    reload
  end

  private

  def initialize
    super
    set_visible true
    set_sort_func {|a,b|
      encounter.initiative_for(b) <=> encounter.initiative_for(a)
    }
  end

end

class EncounterUI::ListBoxRow < CastMemberRow
  def reset_text
    @text = nil
    @label.set_markup text
  end

  def text
    @text ||= begin
      initiative = Game.instance.encounter.initiative_for(@character).to_i
      ctrl = character.is_pc ? green('P') : red('N')
      "%2d: %s %s" % [initiative, ctrl, colored_character(@character, true)]
    end
  end
end

module EncounterUI::Functions
  # Replace Game.instance.encounter with a new Encounter
  def new_encounter
    Game.instance.new_encounter
  end

  # Put current encounter into Game.instance.encounters
  def save_encounter
    Game.instance.store_encounter
  end
end
